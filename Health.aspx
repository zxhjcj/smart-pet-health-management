<%@ Page Language="C#" MasterPageFile="~/Site.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">健康记录与提醒</h1>
    <asp:Panel ID="MessagePanel" runat="server" Visible="false" CssClass="message ok">
        <asp:Literal ID="MessageText" runat="server" />
    </asp:Panel>
    <section class="panel">
        <h2 class="section-title">记录健康指标</h2>
        <div class="grid grid-2">
            <div class="form-row">
                <label for="PetList">宠物</label>
                <asp:DropDownList ID="PetList" runat="server" />
            </div>
            <div class="form-row">
                <label for="RecordDateText">记录日期</label>
                <asp:TextBox ID="RecordDateText" runat="server" TextMode="Date" />
            </div>
            <div class="form-row">
                <label for="WeightText">体重 kg</label>
                <asp:TextBox ID="WeightText" runat="server" TextMode="Number" />
            </div>
            <div class="form-row">
                <label for="TemperatureText">体温</label>
                <asp:TextBox ID="TemperatureText" runat="server" TextMode="Number" />
            </div>
            <div class="form-row">
                <label for="AppetiteText">饮食情况</label>
                <asp:TextBox ID="AppetiteText" runat="server" MaxLength="30" />
            </div>
            <div class="form-row">
                <label for="ExerciseText">运动时长 分钟</label>
                <asp:TextBox ID="ExerciseText" runat="server" TextMode="Number" />
            </div>
        </div>
        <div class="form-row">
            <label for="SymptomText">症状描述</label>
            <asp:TextBox ID="SymptomText" runat="server" TextMode="MultiLine" />
        </div>
        <asp:Button ID="SaveHealthButton" runat="server" Text="保存健康记录" OnClick="SaveHealthButton_Click" />
    </section>
    <section class="panel">
        <h2 class="section-title">新增疫苗/驱虫提醒</h2>
        <div class="grid grid-2">
            <div class="form-row">
                <label for="ReminderPetList">宠物</label>
                <asp:DropDownList ID="ReminderPetList" runat="server" />
            </div>
            <div class="form-row">
                <label for="ReminderTypeList">提醒类型</label>
                <asp:DropDownList ID="ReminderTypeList" runat="server">
                    <asp:ListItem>疫苗</asp:ListItem>
                    <asp:ListItem>驱虫</asp:ListItem>
                    <asp:ListItem>体检</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="form-row">
                <label for="ReminderTitleText">标题</label>
                <asp:TextBox ID="ReminderTitleText" runat="server" MaxLength="100" />
            </div>
            <div class="form-row">
                <label for="RemindAtText">提醒日期</label>
                <asp:TextBox ID="RemindAtText" runat="server" TextMode="Date" />
            </div>
        </div>
        <asp:Button ID="SaveReminderButton" runat="server" Text="保存提醒" OnClick="SaveReminderButton_Click" />
    </section>
    <section class="panel">
        <h2 class="section-title">健康记录列表</h2>
        <asp:GridView ID="HealthGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None" EmptyDataText="暂无健康记录">
            <Columns>
                <asp:BoundField DataField="PetName" HeaderText="宠物" />
                <asp:BoundField DataField="RecordDate" HeaderText="日期" DataFormatString="{0:yyyy-MM-dd}" />
                <asp:BoundField DataField="WeightKg" HeaderText="体重" DataFormatString="{0:N2}" />
                <asp:BoundField DataField="Temperature" HeaderText="体温" DataFormatString="{0:N1}" />
                <asp:BoundField DataField="Appetite" HeaderText="饮食" />
                <asp:BoundField DataField="Symptom" HeaderText="症状" />
                <asp:BoundField DataField="AbnormalMessage" HeaderText="提示" />
            </Columns>
        </asp:GridView>
    </section>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            Auth.RequireLogin();
            if (!IsPostBack)
            {
                RecordDateText.Text = DateTime.Today.ToString("yyyy-MM-dd");
                RemindAtText.Text = DateTime.Today.AddDays(7).ToString("yyyy-MM-dd");
                BindPets();
                BindHealth();
            }
        }

        protected void SaveHealthButton_Click(object sender, EventArgs e)
        {
            if (PetList.Items.Count == 0)
            {
                ShowMessage("请先新增宠物档案。");
                return;
            }

            string abnormal = GetAbnormalMessage();
            Db.Execute(
                @"INSERT INTO dbo.HealthRecords(PetId, RecordDate, WeightKg, Temperature, Appetite, ExerciseMinutes, Symptom, IsAbnormal, AbnormalMessage)
                  VALUES(@PetId, @RecordDate, @WeightKg, @Temperature, @Appetite, @ExerciseMinutes, @Symptom, @IsAbnormal, @AbnormalMessage)",
                Db.Param("@PetId", PetList.SelectedValue),
                Db.Param("@RecordDate", RecordDateText.Text),
                Db.Param("@WeightKg", EmptyToNull(WeightText.Text)),
                Db.Param("@Temperature", EmptyToNull(TemperatureText.Text)),
                Db.Param("@Appetite", AppetiteText.Text.Trim()),
                Db.Param("@ExerciseMinutes", EmptyToNull(ExerciseText.Text)),
                Db.Param("@Symptom", SymptomText.Text.Trim()),
                Db.Param("@IsAbnormal", abnormal.Length > 0),
                Db.Param("@AbnormalMessage", abnormal));

            if (abnormal.Length > 0)
            {
                CreateReminder(Convert.ToInt32(PetList.SelectedValue), "健康异常", "健康异常预警", abnormal, DateTime.Now);
            }

            WeightText.Text = "";
            TemperatureText.Text = "";
            AppetiteText.Text = "";
            ExerciseText.Text = "";
            SymptomText.Text = "";
            BindHealth();
            ShowMessage(abnormal.Length > 0 ? "健康记录已保存，并生成异常提醒。" : "健康记录已保存。");
        }

        protected void SaveReminderButton_Click(object sender, EventArgs e)
        {
            if (ReminderPetList.Items.Count == 0)
            {
                ShowMessage("请先新增宠物档案。");
                return;
            }

            string title = string.IsNullOrEmpty(ReminderTitleText.Text.Trim()) ? ReminderTypeList.SelectedValue + "提醒" : ReminderTitleText.Text.Trim();
            CreateReminder(Convert.ToInt32(ReminderPetList.SelectedValue), ReminderTypeList.SelectedValue, title, "请及时处理宠物健康事项。", Convert.ToDateTime(RemindAtText.Text));
            ReminderTitleText.Text = "";
            ShowMessage("提醒已保存，可在站内提醒页面查看。");
        }

        private void BindPets()
        {
            System.Data.DataTable pets = Db.Query("SELECT PetId, PetName FROM dbo.Pets WHERE UserId=@UserId AND IsDeleted=0 ORDER BY PetName", Db.Param("@UserId", Auth.UserId));
            PetList.DataSource = pets;
            PetList.DataTextField = "PetName";
            PetList.DataValueField = "PetId";
            PetList.DataBind();
            ReminderPetList.DataSource = pets.Copy();
            ReminderPetList.DataTextField = "PetName";
            ReminderPetList.DataValueField = "PetId";
            ReminderPetList.DataBind();
        }

        private void BindHealth()
        {
            HealthGrid.DataSource = Db.Query(
                @"SELECT TOP 50 p.PetName, h.RecordDate, h.WeightKg, h.Temperature, h.Appetite, h.Symptom, h.AbnormalMessage
                  FROM dbo.HealthRecords h
                  INNER JOIN dbo.Pets p ON h.PetId=p.PetId
                  WHERE p.UserId=@UserId AND p.IsDeleted=0
                  ORDER BY h.RecordDate DESC, h.HealthRecordId DESC",
                Db.Param("@UserId", Auth.UserId));
            HealthGrid.DataBind();
        }

        private string GetAbnormalMessage()
        {
            decimal temp;
            if (decimal.TryParse(TemperatureText.Text, out temp) && (temp < 37 || temp > 39.5M))
            {
                return "体温可能异常，请持续观察并及时就医。";
            }

            if (!string.IsNullOrEmpty(SymptomText.Text.Trim()))
            {
                string symptom = SymptomText.Text;
                if (symptom.Contains("呕吐") || symptom.Contains("腹泻") || symptom.Contains("抽搐") || symptom.Contains("便血"))
                {
                    return "症状存在风险，请尽快咨询兽医。";
                }
            }

            return "";
        }

        private void CreateReminder(int petId, string type, string title, string content, DateTime remindAt)
        {
            Db.Execute(
                @"INSERT INTO dbo.Reminders(UserId, PetId, ReminderType, Title, Content, RemindAt, Status)
                  VALUES(@UserId, @PetId, @ReminderType, @Title, @Content, @RemindAt, N'Pending')",
                Db.Param("@UserId", Auth.UserId),
                Db.Param("@PetId", petId),
                Db.Param("@ReminderType", type),
                Db.Param("@Title", title),
                Db.Param("@Content", content),
                Db.Param("@RemindAt", remindAt));
        }

        private object EmptyToNull(string value)
        {
            return string.IsNullOrEmpty(value.Trim()) ? null : (object)value.Trim();
        }

        private void ShowMessage(string text)
        {
            MessagePanel.Visible = true;
            MessageText.Text = Server.HtmlEncode(text);
        }
    </script>
</asp:Content>


