using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace fix_log_api.Migrations
{
    /// <inheritdoc />
    public partial class AddCostToReport : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "Cost",
                table: "Reports",
                type: "numeric",
                nullable: false,
                defaultValue: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Cost",
                table: "Reports");
        }
    }
}
