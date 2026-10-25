<%@ Page Language="C#" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Auth.Logout();
        Response.Redirect("~/Login.aspx");
    }
</script>

