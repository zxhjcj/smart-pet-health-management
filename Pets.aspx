<%@ Page Language="C#" MasterPageFile="~/Site.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">宠物档案管理</h1>
    <asp:Panel ID="MessagePanel" runat="server" Visible="false" CssClass="message ok">
        <asp:Literal ID="MessageText" runat="server" />
    </asp:Panel>
    <section class="panel">
        <h2 class="section-title"><asp:Literal ID="FormTitle" runat="server" Text="新增宠物档案" /></h2>
        <asp:HiddenField ID="PetIdField" runat="server" />
        <div class="grid grid-2">
            <div class="form-row">
                <label for="PetNameText">宠物名称</label>
                <asp:TextBox ID="PetNameText" runat="server" MaxLength="50" />
            </div>
            <div class="form-row">
                <label for="SpeciesText">类型</label>
                <asp:TextBox ID="SpeciesText" runat="server" MaxLength="30" placeholder="例如：猫、狗" />
            </div>
            <div class="form-row">
                <label for="BreedText">品种</label>
                <asp:TextBox ID="BreedText" runat="server" MaxLength="50" />
            </div>
            <div class="form-row">
                <label for="GenderList">性别</label>
                <asp:DropDownList ID="GenderList" runat="server">
                    <asp:ListItem>未知</asp:ListItem>
                    <asp:ListItem>公</asp:ListItem>
                    <asp:ListItem>母</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="form-row">
                <label for="BirthdayText">出生日期</label>
                <asp:TextBox ID="BirthdayText" runat="server" TextMode="Date" />
            </div>
            <div class="form-row">
                <label for="AgeText">年龄</label>
                <asp:TextBox ID="AgeText" runat="server" TextMode="Number" />
            </div>
            <div class="form-row">
                <label for="WeightText">体重 kg</label>
                <asp:TextBox ID="WeightText" runat="server" TextMode="Number" />
            </div>
            <div class="form-row">
                <label for="PhotoUrlText">照片地址</label>
                <asp:TextBox ID="PhotoUrlText" runat="server" MaxLength="255" />
            </div>
        </div>
        <div class="form-row">
            <label for="DescriptionText">备注</label>
            <asp:TextBox ID="DescriptionText" runat="server" TextMode="MultiLine" />
        </div>
        <asp:Button ID="SaveButton" runat="server" Text="保存档案" OnClick="SaveButton_Click" />
        <asp:Button ID="CancelButton" runat="server" Text="取消编辑" CssClass="secondary" OnClick="CancelButton_Click" />
    </section>
    <section class="panel">
        <h2 class="section-title">我的宠物</h2>
        <asp:GridView ID="PetGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None"
            DataKeyNames="PetId" OnRowCommand="PetGrid_RowCommand" EmptyDataText="暂无宠物档案">
            <Columns>
                <asp:BoundField DataField="PetName" HeaderText="名称" />
                <asp:BoundField DataField="Species" HeaderText="类型" />
                <asp:BoundField DataField="Breed" HeaderText="品种" />
                <asp:BoundField DataField="Gender" HeaderText="性别" />
                <asp:BoundField DataField="Age" HeaderText="年龄" />
                <asp:BoundField DataField="WeightKg" HeaderText="体重" DataFormatString="{0:N2}" />
                <asp:ButtonField Text="编辑" CommandName="EditPet" ButtonType="Button" />
                <asp:ButtonField Text="删除" CommandName="DeletePet" ButtonType="Button" />
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
                CancelButton.Visible = false;
            }
        }

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(PetNameText.Text.Trim()) || string.IsNullOrEmpty(SpeciesText.Text.Trim()))
            {
                ShowMessage("请填写宠物名称和类型。");
                return;
            }

            string petId = PetIdField.Value;
            if (string.IsNullOrEmpty(petId))
            {
                Db.Execute(
                    @"INSERT INTO dbo.Pets(UserId, PetName, Species, Breed, Gender, Birthday, Age, WeightKg, PhotoUrl, Description)
                      VALUES(@UserId, @PetName, @Species, @Breed, @Gender, @Birthday, @Age, @WeightKg, @PhotoUrl, @Description)",
                    Db.Param("@UserId", Auth.UserId),
                    Db.Param("@PetName", PetNameText.Text.Trim()),
                    Db.Param("@Species", SpeciesText.Text.Trim()),
                    Db.Param("@Breed", BreedText.Text.Trim()),
                    Db.Param("@Gender", GenderList.SelectedValue),
                    Db.Param("@Birthday", EmptyToNull(BirthdayText.Text)),
                    Db.Param("@Age", EmptyToNull(AgeText.Text)),
                    Db.Param("@WeightKg", EmptyToNull(WeightText.Text)),
                    Db.Param("@PhotoUrl", PhotoUrlText.Text.Trim()),
                    Db.Param("@Description", DescriptionText.Text.Trim()));
                ShowMessage("宠物档案已新增。");
            }
            else
            {
                Db.Execute(
                    @"UPDATE dbo.Pets SET PetName=@PetName, Species=@Species, Breed=@Breed, Gender=@Gender, Birthday=@Birthday,
                        Age=@Age, WeightKg=@WeightKg, PhotoUrl=@PhotoUrl, Description=@Description, UpdatedAt=GETDATE()
                      WHERE PetId=@PetId AND UserId=@UserId",
                    Db.Param("@PetId", petId),
                    Db.Param("@UserId", Auth.UserId),
                    Db.Param("@PetName", PetNameText.Text.Trim()),
                    Db.Param("@Species", SpeciesText.Text.Trim()),
                    Db.Param("@Breed", BreedText.Text.Trim()),
                    Db.Param("@Gender", GenderList.SelectedValue),
                    Db.Param("@Birthday", EmptyToNull(BirthdayText.Text)),
                    Db.Param("@Age", EmptyToNull(AgeText.Text)),
                    Db.Param("@WeightKg", EmptyToNull(WeightText.Text)),
                    Db.Param("@PhotoUrl", PhotoUrlText.Text.Trim()),
                    Db.Param("@Description", DescriptionText.Text.Trim()));
                ShowMessage("宠物档案已更新。");
            }

            ClearForm();
            BindPets();
        }

        protected void PetGrid_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            int index = Convert.ToInt32(e.CommandArgument);
            int petId = Convert.ToInt32(PetGrid.DataKeys[index].Value);
            if (e.CommandName == "DeletePet")
            {
                Db.Execute("UPDATE dbo.Pets SET IsDeleted=1, UpdatedAt=GETDATE() WHERE PetId=@PetId AND UserId=@UserId", Db.Param("@PetId", petId), Db.Param("@UserId", Auth.UserId));
                ShowMessage("宠物档案已删除。");
                BindPets();
            }
            else if (e.CommandName == "EditPet")
            {
                System.Data.DataTable table = Db.Query("SELECT * FROM dbo.Pets WHERE PetId=@PetId AND UserId=@UserId", Db.Param("@PetId", petId), Db.Param("@UserId", Auth.UserId));
                if (table.Rows.Count == 0) return;
                System.Data.DataRow row = table.Rows[0];
                PetIdField.Value = Convert.ToString(row["PetId"]);
                PetNameText.Text = Convert.ToString(row["PetName"]);
                SpeciesText.Text = Convert.ToString(row["Species"]);
                BreedText.Text = Convert.ToString(row["Breed"]);
                GenderList.SelectedValue = Convert.ToString(row["Gender"]);
                BirthdayText.Text = row["Birthday"] == DBNull.Value ? "" : Convert.ToDateTime(row["Birthday"]).ToString("yyyy-MM-dd");
                AgeText.Text = Convert.ToString(row["Age"]);
                WeightText.Text = Convert.ToString(row["WeightKg"]);
                PhotoUrlText.Text = Convert.ToString(row["PhotoUrl"]);
                DescriptionText.Text = Convert.ToString(row["Description"]);
                FormTitle.Text = "编辑宠物档案";
                CancelButton.Visible = true;
            }
        }

        protected void CancelButton_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void BindPets()
        {
            PetGrid.DataSource = Db.Query(@"SELECT PetId, PetName, Species, Breed, Gender, Age, WeightKg FROM dbo.Pets WHERE UserId=@UserId AND IsDeleted=0 ORDER BY CreatedAt DESC", Db.Param("@UserId", Auth.UserId));
            PetGrid.DataBind();
        }

        private void ClearForm()
        {
            PetIdField.Value = "";
            PetNameText.Text = "";
            SpeciesText.Text = "";
            BreedText.Text = "";
            GenderList.SelectedValue = "未知";
            BirthdayText.Text = "";
            AgeText.Text = "";
            WeightText.Text = "";
            PhotoUrlText.Text = "";
            DescriptionText.Text = "";
            FormTitle.Text = "新增宠物档案";
            CancelButton.Visible = false;
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


