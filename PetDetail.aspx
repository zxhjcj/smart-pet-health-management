<%@ Page Language="C#" MasterPageFile="~/Site.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">宠物详细信息</h1>
    <asp:Panel ID="MessagePanel" runat="server" Visible="false" CssClass="message error">
        <asp:Literal ID="MessageText" runat="server" />
    </asp:Panel>
    <asp:Panel ID="DetailPanel" runat="server">
        <section class="panel">
            <h2 class="section-title">基本信息</h2>
            <table class="table">
                <tr><th>名称</th><td><asp:Literal ID="PetNameText" runat="server" /></td></tr>
                <tr><th>类型</th><td><asp:Literal ID="SpeciesText" runat="server" /></td></tr>
                <tr><th>品种</th><td><asp:Literal ID="BreedText" runat="server" /></td></tr>
                <tr><th>性别</th><td><asp:Literal ID="GenderText" runat="server" /></td></tr>
                <tr><th>出生日期</th><td><asp:Literal ID="BirthdayText" runat="server" /></td></tr>
                <tr><th>年龄</th><td><asp:Literal ID="AgeText" runat="server" /></td></tr>
                <tr><th>体重</th><td><asp:Literal ID="WeightText" runat="server" /></td></tr>
                <tr><th>备注</th><td><asp:Literal ID="DescriptionText" runat="server" /></td></tr>
            </table>
        </section>
        <section class="panel">
            <h2 class="section-title">最近健康记录</h2>
            <asp:GridView ID="HealthGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None" EmptyDataText="暂无健康记录">
                <Columns>
                    <asp:BoundField DataField="RecordDate" HeaderText="日期" DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="WeightKg" HeaderText="体重" DataFormatString="{0:N2}" />
                    <asp:BoundField DataField="Temperature" HeaderText="体温" DataFormatString="{0:N1}" />
                    <asp:BoundField DataField="Appetite" HeaderText="饮食" />
                    <asp:BoundField DataField="Symptom" HeaderText="症状" />
                    <asp:BoundField DataField="AbnormalMessage" HeaderText="提示" />
                </Columns>
            </asp:GridView>
        </section>
        <section class="panel">
            <h2 class="section-title">站内提醒</h2>
            <asp:GridView ID="ReminderGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None" EmptyDataText="暂无提醒">
                <Columns>
                    <asp:BoundField DataField="ReminderType" HeaderText="类型" />
                    <asp:BoundField DataField="Title" HeaderText="标题" />
                    <asp:BoundField DataField="RemindAt" HeaderText="提醒时间" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                    <asp:BoundField DataField="Status" HeaderText="状态" />
                </Columns>
            </asp:GridView>
        </section>
        <section class="panel">
            <h2 class="section-title">AI 咨询记录</h2>
            <asp:GridView ID="AiGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None" EmptyDataText="暂无咨询记录">
                <Columns>
                    <asp:BoundField DataField="Question" HeaderText="问题" />
                    <asp:BoundField DataField="Answer" HeaderText="回复" />
                    <asp:BoundField DataField="CreatedAt" HeaderText="时间" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                </Columns>
            </asp:GridView>
        </section>
    </asp:Panel>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            Auth.RequireLogin();
            if (!IsPostBack)
            {
                BindDetail();
            }
        }

        private void BindDetail()
        {
            int petId = 0;
            int.TryParse(Request["id"], out petId);
            if (petId <= 0)
            {
                ShowError("没有找到宠物信息。");
                return;
            }

            System.Data.DataTable table;
            if (Auth.IsAdmin)
            {
                table = Db.Query(
                    "SELECT * FROM dbo.Pets WHERE PetId=@PetId AND IsDeleted=0",
                    Db.Param("@PetId", petId));
            }
            else
            {
                table = Db.Query(
                    "SELECT * FROM dbo.Pets WHERE PetId=@PetId AND UserId=@UserId AND IsDeleted=0",
                    Db.Param("@PetId", petId),
                    Db.Param("@UserId", Auth.UserId));
            }

            if (table.Rows.Count == 0)
            {
                ShowError("没有找到宠物信息。");
                return;
            }

            System.Data.DataRow row = table.Rows[0];
            PetNameText.Text = Convert.ToString(row["PetName"]);
            SpeciesText.Text = Convert.ToString(row["Species"]);
            BreedText.Text = Convert.ToString(row["Breed"]);
            GenderText.Text = Convert.ToString(row["Gender"]);
            BirthdayText.Text = row["Birthday"] == DBNull.Value ? "" : Convert.ToDateTime(row["Birthday"]).ToString("yyyy-MM-dd");
            AgeText.Text = Convert.ToString(row["Age"]);
            WeightText.Text = row["WeightKg"] == DBNull.Value ? "" : Convert.ToString(row["WeightKg"]) + " kg";
            DescriptionText.Text = Convert.ToString(row["Description"]);

            HealthGrid.DataSource = Db.Query(
                @"SELECT TOP 10 RecordDate, WeightKg, Temperature, Appetite, Symptom, AbnormalMessage
                  FROM dbo.HealthRecords
                  WHERE PetId=@PetId
                  ORDER BY RecordDate DESC, HealthRecordId DESC",
                Db.Param("@PetId", petId));
            HealthGrid.DataBind();

            if (Auth.IsAdmin)
            {
                ReminderGrid.DataSource = Db.Query(
                    @"SELECT TOP 10 ReminderType, Title, RemindAt, Status
                      FROM dbo.Reminders
                      WHERE PetId=@PetId
                      ORDER BY RemindAt DESC",
                    Db.Param("@PetId", petId));
            }
            else
            {
                ReminderGrid.DataSource = Db.Query(
                    @"SELECT TOP 10 ReminderType, Title, RemindAt, Status
                      FROM dbo.Reminders
                      WHERE PetId=@PetId AND UserId=@UserId
                      ORDER BY RemindAt DESC",
                    Db.Param("@PetId", petId),
                    Db.Param("@UserId", Auth.UserId));
            }
            ReminderGrid.DataBind();

            if (Auth.IsAdmin)
            {
                AiGrid.DataSource = Db.Query(
                    @"SELECT TOP 10 Question, Answer, CreatedAt
                      FROM dbo.AiConsultations
                      WHERE PetId=@PetId
                      ORDER BY CreatedAt DESC",
                    Db.Param("@PetId", petId));
            }
            else
            {
                AiGrid.DataSource = Db.Query(
                    @"SELECT TOP 10 Question, Answer, CreatedAt
                      FROM dbo.AiConsultations
                      WHERE PetId=@PetId AND UserId=@UserId
                      ORDER BY CreatedAt DESC",
                    Db.Param("@PetId", petId),
                    Db.Param("@UserId", Auth.UserId));
            }
            AiGrid.DataBind();
        }

        private void ShowError(string text)
        {
            DetailPanel.Visible = false;
            MessagePanel.Visible = true;
            MessageText.Text = Server.HtmlEncode(text);
        }
    </script>
</asp:Content>

