package sql

import (
	mysql "database/sql"

	_ "github.com/go-sql-driver/mysql"
)

type Hasher interface {
	Hash(clearText string) string
}

type Verifier interface {
	Verify(clearText string) (bool, error)
}

type SQL interface {
	//	Verifier
	Create(db *mysql.DB) (interface{}, error)
	Update(db *mysql.DB) error
	Delete(db *mysql.DB) error
	List(db *mysql.DB) (interface{}, error)
}

func connect() (*mysql.DB, error) {
	return mysql.Open("mysql", ":@/?charset=utf8")
}

func Create(s SQL) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return -1, err
	}
	return s.Create(db)
}

func Update(s SQL) error {
	db, err := connect()
	if err != nil {
		return err
	}
	return s.Update(db)
}

func Delete(s SQL) error {
	db, err := connect()
	if err != nil {
		return err
	}
	return s.Delete(db)
}

func List(s SQL) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return nil, err
	}
	return s.List(db)
}
