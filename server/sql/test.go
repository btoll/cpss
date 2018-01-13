package sql

import (
	"database/sql"
	"fmt"

	_ "github.com/go-sql-driver/mysql"
)

func Foo() {
	db, err := sql.Open("mysql", "derp:12345@/cpss?charset=utf8")
	if err != nil {
		panic(err)
	}

	fmt.Println()
	fmt.Println("db", db)
	fmt.Println()
}
