import java.io.*;
import java.net.URL;


public class ENVIRONMENT
{

   String vivUser = null;
   String vivPassword = null;
   String vivPort = null;
   String vivHost = null;
   String vivTargetOS = null;
   String vivTargetArch = null;
   String vivVersion = null;
   String vivProject = null;
   String vivVDir = null;
   String vivKillAll = null;
   String testRoot = null;
   String velocityUrl = null;
   String adminUrl = null;
   String gronkUrl = null;
   String collection = null;

   private void getVelocityEnv() {

      this.vivUser = System.getenv("VIVUSER");
      this.vivPassword = System.getenv("VIVPW");
      this.vivHost = System.getenv("VIVHOST");
      this.vivTargetOS = System.getenv("VIVTARGETOS");
      this.vivTargetArch = System.getenv("VIVTARGETARCH");
      this.vivVDir = System.getenv("VIVVIRTUALDIR");
      this.vivKillAll = System.getenv("VIVKILLALL");
      this.vivPort = System.getenv("VIVPORT");
      this.vivVersion = System.getenv("VIVVERSION");
      this.vivProject = System.getenv("VIVPROJECT");
      this.testRoot = System.getenv("TEST_ROOT");
   }

   private void setAllUrls() {
      String velocmd;
      String admincmd;
      String grnkcmd;

      if (this.vivTargetOS.equals("windows")) {
         velocmd = "velocity.exe";
         admincmd = "velocity.exe";
         grnkcmd = "gronk.exe";
      } else {
         velocmd = "velocity";
         admincmd = "velocity";
         grnkcmd = "gronk";
      }

      this.velocityUrl = "http://" + this.vivHost + "/" +
                      this.vivVDir + "/cgi-bin/" + velocmd;

      this.adminUrl = "http://" + this.vivHost + "/" +
                      this.vivVDir + "/cgi-bin/" + admincmd;

      this.gronkUrl = "http://" + this.vivHost + "/" +
                      this.vivVDir + "/cgi-bin/" + grnkcmd;
   }

   private void commonInit() {

      getVelocityEnv();
      setAllUrls();

   }

   public String getVivUser() {
      return(this.vivUser);
   }

   public String getVivPassword() {
      return(this.vivPassword);
   }

   public String getVivPort() {
      return(this.vivPort);
   }

   public String getVivHost() {
      return(this.vivHost);
   }

   public String getVivTargetOS() {
      return(this.vivTargetOS);
   }

   public String getVivTargetArch() {
      return(this.vivTargetArch);
   }

   public String getVivVersion() {
      return(this.vivVersion);
   }

   public String getVivProject() {
      return(this.vivProject);
   }

   public String getVivVDir() {
      return(this.vivVDir);
   }

   public String getVivKillAll() {
      return(this.vivKillAll);
   }

   public String getTestRoot() {
      return(this.testRoot);
   }

   public String getVelocityUrl() {
      return(this.velocityUrl);
   }

   public String getAdminUrl() {
      return(this.adminUrl);
   }

   public String getGronkUrl() {
      return(this.gronkUrl);
   }

   public ENVIRONMENT() {

      commonInit();

   }

}
