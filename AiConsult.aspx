<%@ Page Language="C#" MasterPageFile="~/Site.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">AI 健康顾问</h1>
    <section class="panel">
        <h2 class="section-title">发起咨询</h2>
        <div class="form-row">
            <label for="PetList">宠物</label>
            <asp:DropDownList ID="PetList" runat="server" />
        </div>
        <div class="form-row">
            <label for="QuestionText">健康问题或症状</label>
            <asp:TextBox ID="QuestionText" runat="server" TextMode="MultiLine" />
        </div>
        <asp:Button ID="AskButton" runat="server" Text="获取建议" OnClick="AskButton_Click" />
    </section>
    <asp:Panel ID="AnswerPanel" runat="server" Visible="false" CssClass="panel">
        <h2 class="section-title">AI 建议</h2>
        <p class="preline"><asp:Literal ID="AnswerText" runat="server" /></p>
    </asp:Panel>
    <section class="panel">
        <h2 class="section-title">咨询历史</h2>
        <asp:GridView ID="AiGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None" EmptyDataText="暂无咨询记录">
            <Columns>
                <asp:BoundField DataField="PetName" HeaderText="宠物" />
                <asp:BoundField DataField="Question" HeaderText="问题" />
                <asp:BoundField DataField="Answer" HeaderText="回复" />
                <asp:BoundField DataField="CreatedAt" HeaderText="时间" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
            </Columns>
        </asp:GridView>
    </section>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            Auth.RequireLogin();
            if (!IsPostBack)
            {
                BindPets();
                BindHistory();
            }
        }

        protected void AskButton_Click(object sender, EventArgs e)
        {
            if (PetList.Items.Count == 0)
            {
                AnswerPanel.Visible = true;
                AnswerText.Text = "请先新增宠物档案。";
                return;
            }

            if (string.IsNullOrEmpty(QuestionText.Text.Trim()))
            {
                AnswerPanel.Visible = true;
                AnswerText.Text = "请先输入宠物症状或健康问题。";
                return;
            }

            string answer = AiAdvisor.Reply(PetList.SelectedItem.Text, QuestionText.Text.Trim());
            Db.Execute(
                @"INSERT INTO dbo.AiConsultations(UserId, PetId, Question, Answer, ConsultationType, ModelName, IsRuleBased)
                  VALUES(@UserId, @PetId, @Question, @Answer, N'智能问答', N'本地规则库', 1)",
                Db.Param("@UserId", Auth.UserId),
                Db.Param("@PetId", PetList.SelectedValue),
                Db.Param("@Question", QuestionText.Text.Trim()),
                Db.Param("@Answer", answer));

            AnswerPanel.Visible = true;
            AnswerText.Text = Server.HtmlEncode(answer).Replace("\n", "<br />");
            QuestionText.Text = "";
            BindHistory();
        }

        private void BindPets()
        {
            PetList.DataSource = Db.Query("SELECT PetId, PetName FROM dbo.Pets WHERE UserId=@UserId AND IsDeleted=0 ORDER BY PetName", Db.Param("@UserId", Auth.UserId));
            PetList.DataTextField = "PetName";
            PetList.DataValueField = "PetId";
            PetList.DataBind();
        }

        private void BindHistory()
        {
            AiGrid.DataSource = Db.Query(
                @"SELECT TOP 20 ISNULL(p.PetName, N'-') AS PetName, a.Question, a.Answer, a.CreatedAt
                  FROM dbo.AiConsultations a
                  LEFT JOIN dbo.Pets p ON a.PetId=p.PetId
                  WHERE a.UserId=@UserId
                  ORDER BY a.CreatedAt DESC",
                Db.Param("@UserId", Auth.UserId));
            AiGrid.DataBind();
        }
    </script>
</asp:Content>


