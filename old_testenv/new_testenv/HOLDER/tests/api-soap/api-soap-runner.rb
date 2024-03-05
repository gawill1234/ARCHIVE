#!/usr/bin/env ruby

require 'cgi'
require 'fileutils'
require 'rubygems'
require 'nokogiri'
require 'testenv'

# nunit-console.exe c:\source\testenv\tests\api-soap\api-soap\bin\Debug\api-soap.dll /run:APITests.CollectionBrokerEnqueue /output:"c:\testresults\output_ CollectionBrokerEnqueue.txt" /err:"c:\testresults\error_ CollectionBrokerEnqueue.txt" /xml:"c:\testresults\TestResults_ CollectionBrokerEnqueue.xml" /labels

class NunitRunner
  # Just wire it (gag me).
  Nunit_Home = 'C:\\Program Files\\NUnit 2.6.2\\bin'
  Nunit_Console = '"%s\\nunit-console.exe"' % Nunit_Home
  Nunit_Framework = '"%s\\framework"' % Nunit_Home
  Runner_Host = ENV['EVaultSimRunner'] || 'testbed8.test.vivisimo.com'
  Identity_File = "#{ENV['TEST_ROOT']}/files/ssh_private_key"
  Win_Home = 'C:\\Documents and Settings\\Administrator'

  def initialize
    File.chmod(0600, Identity_File)
    File.open('ssh_config', 'w') do |f|
      f.write "IdentityFile #{Identity_File}\nStrictHostKeyChecking no\n"
    end
    @my_name =  "nunit-#{$$}"
    @ssh_target = "administrator@#{Runner_Host}"
    app_config

    # Copy the stuff over to the remote Windows machine
    sftp(["mkdir #{@my_name}",
          "cd #{@my_name}",
          "put #{ENV['TEST_ROOT']}/tests/api-soap/api-soap/bin/api-soap.dll",
          "put #{ENV['TEST_ROOT']}/tests/api-soap/api-soap/bin/nunit.framework.dll",
          "put #{ENV['TEST_ROOT']}/tests/api-soap/api-soap/bin/log4net.dll",
          "put #{ENV['TEST_ROOT']}/tests/api-soap/api-soap/*.xml",
          "put app.config api-soap.dll.config"])

    # Copy the nunit stuff into place...
    ssh(['cd', '"%s\\%s"' % [Win_Home, @my_name],
         '&', 'copy', Nunit_Framework, '.'])
  end

  def app_config
    # Pluck out the VIV* environment and set the url related stuff
    empty, virtual_dir, path, script_name  = TESTENV.velocity.path.split('/')

    config = '<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <configSections>
    <section name="log4net" type="log4net.Config.Log4NetConfigurationSectionHandler,log4net" />
  </configSections>
  <log4net>
    <root>
      <level value="INFO" />
      <appender-ref ref="LogFileAppender" />
    </root>
    <appender name="LogFileAppender" type="log4net.Appender.RollingFileAppender" >
    <file value="APISoap_logfile.txt" />
      <appendToFile value="true" />
      <encoding value="unicodeFFFE" />
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="[%%thread] %%-5level %%logger [%%property{NDC}] - %%message%%newline" />
      </layout>
    </appender>
  </log4net>
  <appSettings>
    <add key="username" value="%s" />
    <add key="password" value="%s" />
    <add key="serverlist" value="%s://%s:%s/%s/%s/%s?v.app=api-soap" />
  </appSettings>
  <system.serviceModel>
    <bindings />
    <client />
  </system.serviceModel>
</configuration>' % [CGI.escape(TESTENV.user),
                     CGI.escape(TESTENV.password),
                     TESTENV.velocity.scheme,
                     TESTENV.velocity.host,
                     TESTENV.velocity.port,
                     virtual_dir,
                     path,
                     script_name]

    File.open('app.config', 'w') do |f|
      f.write(config.split("\n").join("\r\n")+"\r\n")
    end
  end

  def ssh(cmd)
    ssh_cmd = ['ssh', '-F', 'ssh_config', @ssh_target, 'cmd', '/c'] + cmd
    # DEBUG only: puts ssh_cmd.join(' ')
    system(*ssh_cmd)
  end

  def sftp(script)
    File.open('sftp_script', 'w') do |f|
      script.each{|l| f.write(l+"\n")}
    end
    system(*['sftp', '-F', 'ssh_config', '-b', 'sftp_script', @ssh_target])
  end

  def run(test)
    # Run the test(s) on the remote Windows machine.
    status = ssh(['cd', '"%s\\%s"' % [Win_Home, @my_name],
                  '&', Nunit_Console, 'api-soap.dll', '/labels',
                  '/run:%s' % test])
    # Bring back the test results XML file.
    sftp(["cd #{@my_name}",
          "get TestResult.xml",
          "rm TestResult.xml",
          "get APISoap_logfile.txt",
          "rm APISoap_logfile.txt"])
    begin
      FileUtils.mv('TestResult.xml', test + '.xml')
    rescue
      puts 'Move of TestResult.xml failed'
    end
    status
  end

  def cleanup
    ssh(['cd', '"%s"' % Win_Home, '&', 'rmdir', '/q', '/s', @my_name])
  end
end

if __FILE__ == $0
  require 'misc'
  results = TestResults.new('Run C# API Tests from a remote Windows machine.')
  results.fail_severity = 'error-unknown' # Don't fail the test on "errors-high"
  nunit_runner = NunitRunner.new
  # Use my name (presuming a symbolic link) for the test to run
  test_list = [File.basename($0, '.tst')]
  test_list = ARGV unless ARGV.empty?
  test_list.each {|test|
    msg "Running #{test} ..."
    results.add(nunit_runner.run(test), test)
  }
  nunit_runner.cleanup
  results.cleanup_and_exit!
end
