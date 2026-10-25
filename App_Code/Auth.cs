using System;
using System.Data;
using System.Security.Cryptography;
using System.Text;
using System.Web;

public static class Auth
{
    public static int UserId
    {
        get { return HttpContext.Current.Session["UserId"] == null ? 0 : Convert.ToInt32(HttpContext.Current.Session["UserId"]); }
    }

    public static string UserName
    {
        get { return Convert.ToString(HttpContext.Current.Session["UserName"] ?? string.Empty); }
    }

    public static string Role
    {
        get { return Convert.ToString(HttpContext.Current.Session["Role"] ?? string.Empty); }
    }

    public static bool IsLoggedIn
    {
        get { return UserId > 0; }
    }

    public static bool IsAdmin
    {
        get { return Role == "Admin"; }
    }

    public static void RequireLogin()
    {
        if (!IsLoggedIn)
        {
            HttpContext.Current.Response.Redirect("~/Login.aspx");
        }
    }

    public static void RequireAdmin()
    {
        RequireLogin();
        if (!IsAdmin)
        {
            HttpContext.Current.Response.Redirect("~/Default.aspx");
        }
    }

    public static bool Login(string userName, string password, out string error)
    {
        error = string.Empty;
        DataTable table = Db.Query(
            "SELECT TOP 1 UserId, UserName, PasswordHash, Role, IsEnabled FROM dbo.Users WHERE UserName=@UserName",
            Db.Param("@UserName", userName));

        if (table.Rows.Count == 0)
        {
            error = "账号不存在";
            return false;
        }

        DataRow row = table.Rows[0];
        if (!Convert.ToBoolean(row["IsEnabled"]))
        {
            error = "账号已被禁用";
            return false;
        }

        string stored = Convert.ToString(row["PasswordHash"]);
        bool passwordOk = stored == password || stored == HashPassword(password) || stored == HashPasswordOld(password);
        if (!passwordOk)
        {
            error = "密码错误";
            return false;
        }

        HttpContext.Current.Session["UserId"] = Convert.ToInt32(row["UserId"]);
        HttpContext.Current.Session["UserName"] = Convert.ToString(row["UserName"]);
        HttpContext.Current.Session["Role"] = Convert.ToString(row["Role"]);
        if (stored == HashPasswordOld(password))
        {
            Db.Execute("UPDATE dbo.Users SET PasswordHash=@PasswordHash WHERE UserId=@UserId",
                Db.Param("@PasswordHash", HashPassword(password)),
                Db.Param("@UserId", row["UserId"]));
        }
        Db.Execute("UPDATE dbo.Users SET LastLoginAt=GETDATE() WHERE UserId=@UserId", Db.Param("@UserId", row["UserId"]));
        return true;
    }

    public static void Logout()
    {
        HttpContext.Current.Session.Clear();
    }

    public static string HashPassword(string password)
    {
        MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
        byte[] bytes = Encoding.Unicode.GetBytes(password == null ? "" : password);
        return Convert.ToBase64String(md5.ComputeHash(bytes));
    }

    private static string HashPasswordOld(string password)
    {
        SHA256CryptoServiceProvider sha = new SHA256CryptoServiceProvider();
        byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password == null ? "" : password));
        return BitConverter.ToString(bytes).Replace("-", "").ToLower();
    }
}


