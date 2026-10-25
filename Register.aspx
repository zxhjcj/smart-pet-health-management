<%@ Page Language="C#" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>注册 - 智能宠物健康管理系统</title>
    <link href="Content/site.css?v=3" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server" class="auth-shell">
        <section class="auth-card">
            <h1 class="page-title">注册账号</h1>
            <asp:Panel ID="MessagePanel" runat="server" Visible="false" CssClass="message error">
                <asp:Literal ID="MessageText" runat="server" />
            </asp:Panel>
            <div class="form-row">
                <label for="UserNameText">账号</label>
                <asp:TextBox ID="UserNameText" runat="server" MaxLength="50" />
            </div>
            <div class="form-row">
                <label for="EmailText">邮箱</label>
                <asp:TextBox ID="EmailText" runat="server" MaxLength="100" />
            </div>
            <div class="form-row">
                <label for="NickNameText">昵称</label>
                <asp:TextBox ID="NickNameText" runat="server" MaxLength="50" />
            </div>
            <div class="form-row">
                <label for="PasswordText">密码</label>
                <asp:TextBox ID="PasswordText" runat="server" TextMode="Password" />
            </div>
            <asp:Button ID="RegisterButton" runat="server" Text="注册" OnClick="RegisterButton_Click" />
            <p class="muted">已有账号？<a href="Login.aspx">返回登录</a></p>
        </section>
    </form>
    <script runat="server">
        protected void RegisterButton_Click(object sender, EventArgs e)
        {
            string userName = UserNameText.Text.Trim();
            string email = EmailText.Text.Trim();
            string password = PasswordText.Text;

            if (userName.Length < 3 || password.Length < 6 || !email.Contains("@"))
            {
                ShowError("请填写有效账号、邮箱和至少 6 位密码。");
                return;
            }

            try
            {
                Db.Execute(
                    @"INSERT INTO dbo.Users(UserName, PasswordHash, NickName, Email, Role, IsEnabled, ReminderPreference)
                      VALUES(@UserName, @PasswordHash, @NickName, @Email, N'User', 1, N'站内提醒')",
                    Db.Param("@UserName", userName),
                    Db.Param("@PasswordHash", Auth.HashPassword(password)),
                    Db.Param("@NickName", NickNameText.Text.Trim()),
                    Db.Param("@Email", email));
            }
            catch (Exception ex)
            {
                ShowError("注册失败：" + ex.Message);
                return;
            }

            string loginError;
            if (!Auth.Login(userName, password, out loginError))
            {
                ShowError("注册成功，但自动登录失败：" + loginError + "。请返回登录页手动登录。");
                return;
            }

            Response.Redirect("~/Default.aspx");
        }

        private void ShowError(string text)
        {
            MessagePanel.Visible = true;
            MessageText.Text = Server.HtmlEncode(text);
        }
    </script>
</body>
</html>


