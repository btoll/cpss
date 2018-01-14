package sql

import (
	mysql "database/sql"

	"github.com/btoll/cpss/server/app"
	_ "github.com/go-sql-driver/mysql"
)

func connect() (*mysql.DB, error) {
	return mysql.Open("mysql", ":@/?charset=utf8")
}

func exec(stmt *mysql.Stmt, p *app.SpecialistPayload) (mysql.Result, error) {
	return stmt.Exec(p.Username, p.Password, p.Firstname, p.Lastname, p.Email, p.Payrate)
}

func Create(payload interface{}) (int, error) {
	var id int64
	switch p := payload.(type) {
	case *app.SpecialistPayload:
		db, err := connect()
		if err != nil {
			return -1, err
		}
		s := NewSpecialist()
		id, err = s.Create(db, p)
		if err != nil {
			return -1, err
		}
	}
	return int(id), nil
}

func List() (*app.SpecialistMediaCollection, error) {
	db, err := connect()
	if err != nil {
		panic(err)
	}
	s := NewSpecialist()
	return s.List(db)
}
