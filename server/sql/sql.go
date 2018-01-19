package sql

import (
	"crypto/sha256"
	mysql "database/sql"
	"fmt"

	"github.com/btoll/cpss/server/app"
	_ "github.com/go-sql-driver/mysql"
)

type Hasher interface {
	Hash(clearText string) string
}

type SQL interface {
	//	Verifier
	Create(db *mysql.DB) (interface{}, error)
	Read(db *mysql.DB) (interface{}, error)
	Update(db *mysql.DB) error
	Delete(db *mysql.DB) error
	List(db *mysql.DB) (interface{}, error)
}

type Verifier interface {
	Verify(clearText string) (bool, error)
}

func cleanup(db *mysql.DB) error {
	return db.Close()
}

func connect() (*mysql.DB, error) {
	return mysql.Open("mysql", ":@/?charset=utf8")
}

func hash(clearText string) string {
	h := sha256.New()
	h.Write([]byte(clearText))
	// %x -> base 16, with lower-case letters for a-f
	return fmt.Sprintf("%x", h.Sum(nil))
}

func Create(s SQL) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return -1, err
	}
	rec, err := s.Create(db)
	if err != nil {
		return -1, err
	}
	cleanup(db)
	return rec, nil
}

func Read(s SQL) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return nil, err
	}
	coll, err := s.Read(db)
	if err != nil {
		return nil, err
	}
	cleanup(db)
	return coll, nil
}

func Update(s SQL) error {
	db, err := connect()
	if err != nil {
		return err
	}
	err = s.Update(db)
	if err != nil {
		return err
	}
	cleanup(db)
	return nil
}

func Delete(s SQL) error {
	db, err := connect()
	if err != nil {
		return err
	}
	err = s.Delete(db)
	cleanup(db)
	return nil
}

func List(s SQL) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return nil, err
	}
	coll, err := s.List(db)
	if err != nil {
		return nil, err
	}
	cleanup(db)
	return coll, nil
}

func VerifyPassword(username, password string) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return false, err
	}
	stmt, err := db.Prepare("SELECT email, authLevel FROM specialist WHERE username=? AND password=?")
	if err != nil {
		return false, err
	}
	hashed := hash(password)
	row := stmt.QueryRow(&username, &hashed)
	var email string
	var authLevel int
	err = row.Scan(&email, &authLevel)
	if err != nil {
		return nil, err
	}
	return &app.LoginMedia{
		Username:  username,
		Password:  hashed,
		Email:     email,
		AuthLevel: authLevel,
	}, nil
}
