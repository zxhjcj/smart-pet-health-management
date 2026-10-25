<%@ Page Language="C#" MasterPageFile="~/Site.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">站内提醒</h1>
    <asp:Panel ID="MessagePanel" runat="server" Visible="false" CssClass="message ok">
        <asp:Literal ID="MessageText" runat="server" />
    </asp:Panel>
    <section class="panel">
        <asp:GridView ID="ReminderGrid" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None"
            DataKeyNames="ReminderId" OnRowCommand="ReminderGrid_RowCommand" EmptyDataText="暂无提醒">
            <Columns>
                <asp:BoundField DataField="PetName" HeaderText="宠物" />
                <asp:BoundField DataField="ReminderType" HeaderText="类型" />
                <asp:BoundField DataField="Title" HeaderText="标题" />
                <asp:BoundField DataField="Content" HeaderText="内容" />
                <asp:BoundField DataField="RemindAt" HeaderText="提醒时间" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                <asp:BoundField DataField="Status" HeaderText="状态" />
                <asp:ButtonField Text="标记已读" CommandName="ReadItem" ButtonType="Button" />
            </Columns>
        </asp:GridView>
    </section>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            Auth.RequireLogin();
            if (!IsPostBack) BindData();
        }

        protected void ReminderGrid_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ReadItem")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                int id = Convert.ToInt32(ReminderGrid.DataKeys[index].Value);
                Db.Execute("UPDATE dbo.Reminders SET Status=N'Read', SentAt=GETDATE() WHERE ReminderId=@ReminderId AND UserId=@UserId", Db.Param("@ReminderId", id), Db.Param("@UserId", Auth.UserId));
                MessagePanel.Visible = true;
                MessageText.Text = "提醒已标记为已读。";
                BindData();
            }
        }

        private void BindData()
        {
            ReminderGrid.DataSource = Db.Query(
                @"SELECT r.ReminderId, ISNULL(p.PetName, N'-') AS PetName, r.ReminderType, r.Title, r.Content, r.RemindAt, r.Status
                  FROM dbo.Reminders r
                  LEFT JOIN dbo.Pets p ON r.PetId=p.PetId
                  WHERE r.UserId=@UserId
                  ORDER BY CASE WHEN r.Status=N'Pending' THEN 0 ELSE 1 END, r.RemindAt DESC",
                Db.Param("@UserId", Auth.UserId));
            ReminderGrid.DataBind();
        }
    </script>
</asp:Content>


