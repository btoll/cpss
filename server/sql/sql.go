package sql

import (
	mysql "database/sql"
	"fmt"
	"time"

	"github.com/btoll/cpss/server/app"
	_ "github.com/go-sql-driver/mysql"
	"golang.org/x/crypto/bcrypt"
)

type CRUD interface {
	Create(db *mysql.DB) (interface{}, error)
	Update(db *mysql.DB) (interface{}, error)
	Delete(db *mysql.DB) error
}

type Hasher interface {
	SaltAndHash(pwd []byte) string
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

type PageQuery struct {
	Page        int
	WhereClause string
}

var RecordsPerPage = 50

func cleanup(db *mysql.DB) error {
	return db.Close()
}

func connect() (*mysql.DB, error) {
	return mysql.Open("", "")
}

func getToday() string {
	today := time.Now()
	year, month, day := today.Date()
	// Pad two spaces with leading 0, if needed.
	return fmt.Sprintf("%d-%02d-%02d", year, month, day)
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

func SaltAndHash(pwd string) []byte {
	byteHash, err := bcrypt.GenerateFromPassword([]byte(pwd), bcrypt.DefaultCost)
	if err != nil {
		fmt.Println(err)
		return []byte("Something went terribly wrong")
	}
	return byteHash
}

func VerifyPassword(username, password string) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return false, err
	}
	stmt, err := db.Prepare("SELECT * FROM specialist WHERE username=?")
	if err != nil {
		return nil, err // "Bad username or password"
	}
	row := stmt.QueryRow(&username)
	if err != nil {
		return nil, err
	}
	var id int
	var saltedHash string
	var firstname string
	var lastname string
	var active bool
	var email string
	var payrate float64
	var authLevel int
	err = row.Scan(&id, &username, &saltedHash, &firstname, &lastname, &active, &email, &payrate, &authLevel)
	if err != nil {
		return nil, err
	}
	err = bcrypt.CompareHashAndPassword([]byte(saltedHash), []byte(password))
	if err != nil {
		return nil, err
	}
	return &app.SessionMedia{
		ID:        id,
		Username:  username,
		Password:  saltedHash,
		Firstname: firstname,
		Lastname:  lastname,
		Active:    active,
		Email:     email,
		Payrate:   payrate,
		AuthLevel: authLevel,
	}, nil
}
