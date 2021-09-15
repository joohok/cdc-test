import java.sql.*;
import cubrid.sql.*; //a
import cubrid.jdbc.driver.*;
import java.lang.*;

class OID_Sample
{
   public static void main (String args [])
   {
      // Making a connection
      String url= "jdbc:cubrid:192.168.2.107:30000:delete03db:public::";
      String user = "dba";
      String passwd = "";

      // SQL statement to get OID values
      String sql = "SELECT class_of from _db_class where class_name='delete03' ";
       
      // Declaring variables for Connection and Statement
      Connection con = null;
      Statement stmt = null;
      CUBRIDResultSet rs = null;
      ResultSetMetaData rsmd = null;
      PreparedStatement preStmt = null;

      Object classobj = null;

      try {
         Class.forName("cubrid.jdbc.driver.CUBRIDDriver");
      } catch (ClassNotFoundException e) {
         throw new IllegalStateException("Unable to load Cubrid driver", e);
      }

      try {
         con = DriverManager.getConnection(url, user, passwd);
         stmt = con.createStatement();
         rs = (CUBRIDResultSet)stmt.executeQuery(sql);
         rsmd = rs.getMetaData();
         CUBRIDResultSet rsoid =null;

         rs.next();
         CUBRIDOID oid = rs.getOID(1);
         System.out.println (oid2bytes (oid.getOID()));

         con.commit(); //g

      } catch(CUBRIDException e) {
         e.printStackTrace();

      } catch(SQLException ex) {
         ex.printStackTrace();

      } finally {
         if(rs != null) try { rs.close(); } catch(SQLException e) {}
         if(stmt != null) try { stmt.close(); } catch(SQLException e) {}
         if(con != null) try { con.close(); } catch(SQLException e) {}
      }
   }
   static public long oid2bytes(byte[] oid){
      int page_data = 0;
      short slot_data = 0;
      short volume_data = 0;
      long ret = 0;
      long tmp = 0;
/*OID : (volid | pageid | slotid) */
      int startIndex = 0;
      int endIndex = 4;
/*page ID*/
      if(oid == null) return -1;

      for(int i = startIndex; i< endIndex; i++){
          page_data <<= 8;
          page_data |= (oid[i] & 0xff);
      }
      startIndex = 4;
      endIndex = startIndex + 2;

     for(int i = startIndex; i < endIndex; i++){
        slot_data <<= 8;
        slot_data |= (oid[i] & 0xff);
     }
      startIndex = 6;
      endIndex = startIndex + 2;

      for(int i = startIndex; i < endIndex; i++){
        volume_data <<=8;
        volume_data |= (oid[i] & 0xff);
      }
      ret <<=16;
      ret |= volume_data & 0xffff;

      ret <<=16;
      ret |= slot_data & 0xffff;

      ret <<=32;
      ret |= page_data & 0xffffffff;

      return ret;
   }
}
