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

type CRUD interface {
	Create(db *mysql.DB) (interface{}, error)
	Update(db *mysql.DB) (interface{}, error)
	Delete(db *mysql.DB) error
}

type Lister interface {
	List(db *mysql.DB) (interface{}, error)
}

type Pager interface {
	Page(db *mysql.DB) (interface{}, error)
}

type Reader interface {
	Read(db *mysql.DB) (interface{}, error)
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

func Create(s CRUD) (interface{}, error) {
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

func Read(r Reader) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return nil, err
	}
	coll, err := r.Read(db)
	if err != nil {
		return nil, err
	}
	cleanup(db)
	return coll, nil
}

func Update(s CRUD) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return nil, err
	}
	rec, err := s.Update(db)
	if err != nil {
		return nil, err
	}
	cleanup(db)
	return rec, nil
}

func Delete(s CRUD) error {
	db, err := connect()
	if err != nil {
		return err
	}
	err = s.Delete(db)
	cleanup(db)
	return nil
}

func List(l Lister) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return nil, err
	}
	coll, err := l.List(db)
	if err != nil {
		return nil, err
	}
	cleanup(db)
	return coll, nil
}

func Page(p Pager) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return nil, err
	}
	coll, err := p.Page(db)
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
	stmt, err := db.Prepare("SELECT * FROM specialist WHERE username=? AND password=?")
	if err != nil {
		return false, err
	}
	hashed := Hash(password)
	row := stmt.QueryRow(&username, &hashed)
	var id int
	//	var username string
	//	var password string
	var firstname string
	var lastname string
	var email string
	var payrate float64
	var authLevel int
	err = row.Scan(&id, &username, &password, &firstname, &lastname, &email, &payrate, &authLevel)
	if err != nil {
		return nil, err
	}
	return &app.SessionMedia{
		ID:        id,
		Username:  username,
		Password:  hashed,
		Firstname: firstname,
		Lastname:  lastname,
		Email:     email,
		Payrate:   payrate,
		AuthLevel: authLevel,
	}, nil
}

func Hash(clearText string) string {
	h := sha256.New()
	h.Write([]byte(clearText))
	// %x -> base 16, with lower-case letters for a-f
	return fmt.Sprintf("%x", h.Sum(nil))
}
