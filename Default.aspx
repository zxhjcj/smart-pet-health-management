<%@ Page Language="C#" MasterPageFile="~/Site.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">健康管理总览</h1>
    <div class="grid grid-4">
        <div class="stat">宠物档案<strong><asp:Literal ID="PetCount" runat="server" /></strong></div>
        <div class="stat">健康记录<strong><asp:Literal ID="HealthCount" runat="server" /></strong></div>
        <div class="stat">待处理提醒<strong><asp:Literal ID="ReminderCount" runat="server" /></strong></div>
        <div class="stat">AI 咨询<strong><asp:Literal ID="AiCount" runat="server" /></strong></div>
    </div>
    <section class="panel">
        <h2 class="section-title">宠物查询</h2>
        <div class="grid grid-2">
            <div class="form-row">
                <label for="PetNameSearchText">宠物名称</label>
                <asp:TextBox ID="PetNameSearchText" runat="server" MaxLength="50" />
            </div>
            <div class="form-row">
                <label>&nbsp;</label>
                <asp:Button ID="SearchPetButton" runat="server" Text="查询宠物" OnClick="SearchPetButton_Click" />
            </div>
        </div>
        <asp:Literal ID="SearchMessage" runat="server" />
        <asp:GridView ID="PetSearchGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None" EmptyDataText="请输入宠物名称后查询">
            <Columns>
                <asp:BoundField DataField="PetName" HeaderText="名称" />
                <asp:BoundField DataField="Species" HeaderText="类型" />
                <asp:BoundField DataField="Breed" HeaderText="品种" />
                <asp:BoundField DataField="Gender" HeaderText="性别" />
                <asp:BoundField DataField="WeightKg" HeaderText="体重" DataFormatString="{0:N2}" />
                <asp:BoundField DataField="UserName" HeaderText="所属用户" />
                <asp:HyperLinkField Text="查看详情" DataNavigateUrlFields="PetId" DataNavigateUrlFormatString="PetDetail.aspx?id={0}" HeaderText="操作" />
            </Columns>
        </asp:GridView>
    </section>
    <section class="panel">
        <h2 class="section-title">最近提醒</h2>
        <asp:GridView ID="ReminderGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None" EmptyDataText="暂无提醒">
            <Columns>
                <asp:BoundField DataField="Title" HeaderText="标题" />
                <asp:BoundField DataField="ReminderType" HeaderText="类型" />
                <asp:BoundField DataField="RemindAt" HeaderText="提醒时间" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                <asp:BoundField DataField="Status" HeaderText="状态" />
            </Columns>
        </asp:GridView>
    </section>
    <section class="panel">
        <h2 class="section-title">系统公告</h2>
        <asp:GridView ID="NoticeGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None" EmptyDataText="暂无公告">
            <Columns>
                <asp:BoundField DataField="Title" HeaderText="标题" />
                <asp:BoundField DataField="NoticeType" HeaderText="类型" />
                <asp:BoundField DataField="PublishedAt" HeaderText="发布时间" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
            </Columns>
        </asp:GridView>
    </section>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            Auth.RequireLogin();
            if (!IsPostBack)
            {
                BindData();
            }
        }

        private void BindData()
        {
            PetCount.Text = Convert.ToString(Db.Scalar("SELECT COUNT(*) FROM dbo.Pets WHERE UserId=@UserId AND IsDeleted=0", Db.Param("@UserId", Auth.UserId)));
            HealthCount.Text = Convert.ToString(Db.Scalar(@"SELECT COUNT(*) FROM dbo.HealthRecords h INNER JOIN dbo.Pets p ON h.PetId=p.PetId WHERE p.UserId=@UserId AND p.IsDeleted=0", Db.Param("@UserId", Auth.UserId)));
            ReminderCount.Text = Convert.ToString(Db.Scalar("SELECT COUNT(*) FROM dbo.Reminders WHERE UserId=@UserId AND Status=N'Pending'", Db.Param("@UserId", Auth.UserId)));
            AiCount.Text = Convert.ToString(Db.Scalar("SELECT COUNT(*) FROM dbo.AiConsultations WHERE UserId=@UserId", Db.Param("@UserId", Auth.UserId)));

            ReminderGrid.DataSource = Db.Query(@"SELECT TOP 5 Title, ReminderType, RemindAt, Status FROM dbo.Reminders WHERE UserId=@UserId ORDER BY RemindAt DESC", Db.Param("@UserId", Auth.UserId));
            ReminderGrid.DataBind();

            NoticeGrid.DataSource = Db.Query(@"SELECT TOP 5 Title, NoticeType, PublishedAt FROM dbo.Notices WHERE IsPublished=1 ORDER BY PublishedAt DESC");
            NoticeGrid.DataBind();
        }

        protected void SearchPetButton_Click(object sender, EventArgs e)
        {
            string key = PetNameSearchText.Text.Trim();
            if (string.IsNullOrEmpty(key))
            {
                SearchMessage.Text = "<div class='message error'>请输入宠物名称。</div>";
                PetSearchGrid.DataSource = null;
                PetSearchGrid.DataBind();
                return;
            }

            if (Auth.IsAdmin)
            {
                PetSearchGrid.DataSource = Db.Query(
                    @"SELECT p.PetId, p.PetName, p.Species, p.Breed, p.Gender, p.WeightKg, u.UserName
                      FROM dbo.Pets p
                      INNER JOIN dbo.Users u ON p.UserId=u.UserId
                      WHERE p.IsDeleted=0 AND p.PetName LIKE @PetName
                      ORDER BY p.CreatedAt DESC",
                    Db.Param("@PetName", "%" + key + "%"));
            }
            else
            {
                PetSearchGrid.DataSource = Db.Query(
                    @"SELECT p.PetId, p.PetName, p.Species, p.Breed, p.Gender, p.WeightKg, u.UserName
                      FROM dbo.Pets p
                      INNER JOIN dbo.Users u ON p.UserId=u.UserId
                      WHERE p.UserId=@UserId AND p.IsDeleted=0 AND p.PetName LIKE @PetName
                      ORDER BY p.CreatedAt DESC",
                    Db.Param("@UserId", Auth.UserId),
                    Db.Param("@PetName", "%" + key + "%"));
            }
            PetSearchGrid.DataBind();
            SearchMessage.Text = "";
        }
    </script>
</asp:Content>

