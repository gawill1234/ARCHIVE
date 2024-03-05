require 'set'

class TestResults
  attr_reader :start_iso8601, :end_iso8601, :steps
  attr_accessor :print_severity, :fail_severity, :need_system_report

  def initialize(*description)
    @print_severity = 'warning'
    @fail_severity = 'error-high'
    @need_system_report = true
    @steps = []
    @datastores = []
    msg((["Starting #{File.basename($0)}"] + description).join("\n\t "))
    sleep 1
    @start_iso8601 = iso8601
  end

  def last_step
    @steps[-1]
  end

  def associate(datastore)
    @datastores << datastore
  end

  def add(pass, description, failure=nil)
    @steps << {:pass=>pass, :description=>description}
    last_step[:index] = @steps.length
    if last_step[:pass]
      msg "step #{last_step[:index]} #{pass_color('pass')}: #{last_step[:description]}"
    else
      # We have a failed step. Use the failure description, if available.
      last_step[:description] = failure if failure
      msg "step #{last_step[:index]} #{fail_color('fail')}: #{last_step[:description]}"
    end
  end
  alias :<< :add

  def add_success(description)
    add(true, description, "This should never fail")
  end

  def add_failure(description)
    add(false, "This should never pass", description)
  end

  def add_equals(expected, actual, item_singular)
    add(expected == actual,
        "#{item_singular} matches",
        "#{item_singular} is #{actual}, expected #{expected}")
  end

  def add_number_equals(expected, actual, item_singular, options={})
    if actual == 1
      name = item_singular
    else
      name = options[:plural] || "#{item_singular}s"
    end

    verb = options[:verb] || "Found"
    if options[:qualifier]
      qualifier = " " + options[:qualifier]
    else
      qualifier = ""
    end

    add(expected == actual,
        "#{verb} exactly #{expected} #{name}#{qualifier}",
        "#{verb} #{actual} #{name}#{qualifier}, expected #{expected}")
  end

  def use_plural?(count, item_singular, plural=nil, empty_set=false)
    if count.eql?(1) || (count.zero? && empty_set)
      item_singular
    elsif plural
      plural
    else
      "#{item_singular}s"
    end
  end

  def add_set_equals(expected, actual, item_singular)
    xor = (expected.to_set ^ actual.to_set)
    too_few = expected - actual
    too_many = actual - expected

    if xor.empty?
      add_success(use_plural?(actual.count,
                              "The returned #{item_singular} matches the expec"\
                              "ted value #{expected}.",
                              "The returned #{item_singular}s match the expect"\
                              "ed values #{expected}.",
                              true))
    else
      if not too_few.empty?
        add_failure("The returned #{item_singular} set #{actual} is missing "\
                    "#{too_few}.")
      end

      if not too_many.empty?
        add_failure("The returned #{item_singular} set #{actual} should not ha"\
                    "ve included #{too_many}.")
      end
    end
  end

  def add_matches(regex, actual, options={})
    what = options[:what] || 'string'
    add(actual.match(regex),
        "The #{what} matches",
        "The #{what} #{actual} does not match #{regex}")
  end

  def add_includes(set, actual, options={})
    what = options.fetch(:what) {'value'}

    add(set.include?(actual),
        "The #{what} of #{actual} is in #{set}",
        "The #{what} of #{actual} is not in #{set}")
  end

  def expect_exception(type)
    begin
      yield
      add_failure("Expected #{type} to be thrown, but no exception was thrown")
    rescue => e
      if e.is_a? type
        add_success("#{type} was thrown")
      else
        add_failure("Expected #{type} to be thrown, but #{e} was thrown instead")
        raise e
      end
    end
  end

  def system_report
    @need_system_report = false
    sleep 1
    @end_iso8601 = iso8601
    msg "System Report #{@start_iso8601} to #{@end_iso8601}"
    add(system("#{ENV['TEST_ROOT']}/lib/system_report.py",
               "#{@start_iso8601}",
               "#{@end_iso8601}",
               @print_severity,
               @fail_severity),
        "End of System Report")
  end

  def report
    system_report if @need_system_report
    failed_steps = @steps.reject {|step| step[:pass]}
    if failed_steps.length == 0
      msg "Test #{pass_color('passed')}."
      0                         # Return a Unix-style success code.
    else
      msg "Test #{fail_color('failed')}. #{failed_steps.length} steps failed (out of #{@steps.length}):"
      failed_steps.each {|s| puts "step #{s[:index]} #{fail_color('fail')}: #{s[:description]}"}
      msg "Test #{fail_color('failed')}."
      1                         # Return a Unix-style failure code.
    end
  end

  def clean_datastores(action)
    @datastores.each {|x| x.send(action) if x.respond_to?(action)}
  end

  def cleanup_and_exit!(kill = TESTENV.kill_all_services)
    retval = report

    if TESTENV.delete_on_pass and retval.zero?
      clean_datastores(:delete)
    elsif kill
      clean_datastores(:kill)
    else
      clean_datastores(:stop)
    end
    exit retval
  end

  private

  def pass_color(string)
    if use_color?
      "\033[1;32m#{string}\033[0m"
    else
      string
    end
  end

  def fail_color(string)
    if use_color?
      "\033[1;31m\033[25m#{string}\033[5m\033[0m"
    else
      string
    end
  end

  def use_color?
    option = ENV['TEST_USE_COLOR'] || 'no'

    case option
    when 'auto'
      return $stdout.tty?
    when 'on'
      true
    else
      false
    end
  end
end
