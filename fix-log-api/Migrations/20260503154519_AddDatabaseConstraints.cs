using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace fix_log_api.Migrations
{
    /// <inheritdoc />
    public partial class AddDatabaseConstraints : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.AddCheckConstraint(
                name: "CK_Report_Cost",
                table: "Reports",
                sql: "\"Cost\" >= 0");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Expense_Price",
                table: "Expenses",
                sql: "\"Price\" > 0");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Expense_Quantity",
                table: "Expenses",
                sql: "\"Quantity\" > 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Users_Email",
                table: "Users");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Report_Cost",
                table: "Reports");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Expense_Price",
                table: "Expenses");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Expense_Quantity",
                table: "Expenses");
        }
    }
}
