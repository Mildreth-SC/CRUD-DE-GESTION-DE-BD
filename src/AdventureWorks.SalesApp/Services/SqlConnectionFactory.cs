using Microsoft.Data.SqlClient;

namespace AdventureWorks.SalesApp.Services;

public interface ISqlConnectionFactory
{
    SqlConnection CreateConnection();
}

public class SqlConnectionFactory : ISqlConnectionFactory
{
    private readonly string _connectionString;

    public SqlConnectionFactory(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("AdventureWorksConnection")
            ?? throw new InvalidOperationException("Connection string 'AdventureWorksConnection' not found.");
    }

    public SqlConnection CreateConnection() => new(_connectionString);
}
