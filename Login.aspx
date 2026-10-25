<%@ Page Language="C#" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>登录 - 智能宠物健康管理系统</title>
    <link href="Content/site.css?v=3" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server" class="auth-shell">
        <section class="auth-card">
            <h1 class="page-title">登录系统</h1>
            <asp:Panel ID="MessagePanel" runat="server" Visible="false" CssClass="message error">
                <asp:Literal ID="MessageText" runat="server" />
            </asp:Panel>
            <div class="form-row">
                <label for="UserNameText">账号</label>
                <asp:TextBox ID="UserNameText" runat="server" />
            </div>
            <div class="form-row">
                <label for="PasswordText">密码</label>
                <asp:TextBox ID="PasswordText" runat="server" TextMode="Password" />
            </div>
            <asp:Button ID="LoginButton" runat="server" Text="登录" OnClick="LoginButton_Click" />
            <p class="muted">还没有账号？<a href="Register.aspx">立即注册</a></p>
        </section>
    </form>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Auth.IsLoggedIn)
            {
                Response.Redirect("~/Default.aspx");
            }
        }

        protected void LoginButton_Click(object sender, EventArgs e)
        {
            string error;
            if (Auth.Login(UserNameText.Text.Trim(), PasswordText.Text, out error))
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            MessagePanel.Visible = true;
            MessageText.Text = Server.HtmlEncode(error);
        }
    </script>
</body>
</html>

