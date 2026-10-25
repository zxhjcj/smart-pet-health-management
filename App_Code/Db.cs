using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public static class Db
{
    public static SqlConnection Open()
    {
        SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["SmartPetHealthDb"].ConnectionString);
        connection.Open();
        return connection;
    }

    public static DataTable Query(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection connection = Open())
        using (SqlCommand command = new SqlCommand(sql, connection))
        using (SqlDataAdapter adapter = new SqlDataAdapter(command))
        {
            if (parameters != null)
            {
                command.Parameters.AddRange(parameters);
            }

            DataTable table = new DataTable();
            adapter.Fill(table);
            return table;
        }
    }

    public static int Execute(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection connection = Open())
        using (SqlCommand command = new SqlCommand(sql, connection))
        {
            if (parameters != null)
            {
                command.Parameters.AddRange(parameters);
            }

            return command.ExecuteNonQuery();
        }
    }

    public static object Scalar(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection connection = Open())
        using (SqlCommand command = new SqlCommand(sql, connection))
        {
            if (parameters != null)
            {
                command.Parameters.AddRange(parameters);
            }

            return command.ExecuteScalar();
        }
    }

    public static SqlParameter Param(string name, object value)
    {
        return new SqlParameter(name, value ?? DBNull.Value);
    }
}


