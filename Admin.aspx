<%@ Page Language="C#" MasterPageFile="~/Site.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">后台管理</h1>
    <asp:Panel ID="MessagePanel" runat="server" Visible="false" CssClass="message ok">
        <asp:Literal ID="MessageText" runat="server" />
    </asp:Panel>
    <section class="panel">
        <h2 class="section-title">发布系统公告</h2>
        <div class="grid grid-2">
            <div class="form-row">
                <label for="NoticeTitleText">公告标题</label>
                <asp:TextBox ID="NoticeTitleText" runat="server" MaxLength="100" />
            </div>
            <div class="form-row">
                <label for="NoticeTypeText">公告类型</label>
                <asp:TextBox ID="NoticeTypeText" runat="server" Text="系统公告" MaxLength="30" />
            </div>
        </div>
        <div class="form-row">
            <label for="NoticeContentText">公告内容</label>
            <asp:TextBox ID="NoticeContentText" runat="server" TextMode="MultiLine" />
        </div>
        <asp:Button ID="PublishNoticeButton" runat="server" Text="发布公告" OnClick="PublishNoticeButton_Click" />
    </section>
    <section class="panel">
        <h2 class="section-title">用户管理</h2>
        <asp:GridView ID="UserGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None"
            DataKeyNames="UserId" OnRowCommand="UserGrid_RowCommand" EmptyDataText="暂无用户">
            <Columns>
                <asp:BoundField DataField="UserName" HeaderText="账号" />
                <asp:BoundField DataField="NickName" HeaderText="昵称" />
                <asp:BoundField DataField="Email" HeaderText="邮箱" />
                <asp:BoundField DataField="Role" HeaderText="角色" />
                <asp:CheckBoxField DataField="IsEnabled" HeaderText="启用" />
                <asp:BoundField DataField="CreatedAt" HeaderText="创建时间" DataFormatString="{0:yyyy-MM-dd}" />
                <asp:ButtonField Text="切换启用" CommandName="ToggleUser" ButtonType="Button" />
            </Columns>
        </asp:GridView>
    </section>
    <section class="panel">
        <h2 class="section-title">公告列表</h2>
        <asp:GridView ID="NoticeGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None" EmptyDataText="暂无公告">
            <Columns>
                <asp:BoundField DataField="Title" HeaderText="标题" />
                <asp:BoundField DataField="NoticeType" HeaderText="类型" />
                <asp:BoundField DataField="Content" HeaderText="内容" />
                <asp:BoundField DataField="PublishedAt" HeaderText="发布时间" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
            </Columns>
        </asp:GridView>
    </section>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            Auth.RequireAdmin();
            if (!IsPostBack)
            {
                BindData();
            }
        }

        protected void PublishNoticeButton_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(NoticeTitleText.Text.Trim()) || string.IsNullOrEmpty(NoticeContentText.Text.Trim()))
            {
                ShowMessage("请填写公告标题和内容。");
                return;
            }

            Db.Execute(
                @"INSERT INTO dbo.Notices(AdminUserId, Title, Content, NoticeType, IsPublished, PublishedAt)
                  VALUES(@AdminUserId, @Title, @Content, @NoticeType, 1, GETDATE())",
                Db.Param("@AdminUserId", Auth.UserId),
                Db.Param("@Title", NoticeTitleText.Text.Trim()),
                Db.Param("@Content", NoticeContentText.Text.Trim()),
                Db.Param("@NoticeType", NoticeTypeText.Text.Trim()));
            NoticeTitleText.Text = "";
            NoticeContentText.Text = "";
            NoticeTypeText.Text = "系统公告";
            ShowMessage("公告已发布。");
            BindData();
        }

        protected void UserGrid_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ToggleUser")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                int userId = Convert.ToInt32(UserGrid.DataKeys[index].Value);
                if (userId == Auth.UserId)
                {
                    ShowMessage("不能禁用当前登录管理员。");
                    return;
                }

                Db.Execute("UPDATE dbo.Users SET IsEnabled = CASE WHEN IsEnabled=1 THEN 0 ELSE 1 END, UpdatedAt=GETDATE() WHERE UserId=@UserId", Db.Param("@UserId", userId));
                ShowMessage("用户状态已更新。");
                BindData();
            }
        }

        private void BindData()
        {
            UserGrid.DataSource = Db.Query("SELECT UserId, UserName, NickName, Email, Role, IsEnabled, CreatedAt FROM dbo.Users ORDER BY CreatedAt DESC");
            UserGrid.DataBind();

            NoticeGrid.DataSource = Db.Query("SELECT Title, NoticeType, Content, PublishedAt FROM dbo.Notices ORDER BY CreatedAt DESC");
            NoticeGrid.DataBind();
        }

        private void ShowMessage(string text)
        {
            MessagePanel.Visible = true;
            MessageText.Text = Server.HtmlEncode(text);
        }
    </script>
</asp:Content>


