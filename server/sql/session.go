package sql

import (
	"errors"
	"fmt"

	"github.com/btoll/cpss/server/app"
	"golang.org/x/crypto/bcrypt"
)

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
	var loginTime int
	err = row.Scan(&id, &username, &saltedHash, &firstname, &lastname, &active, &email, &payrate, &authLevel, &loginTime)
	if err != nil {
		return nil, err
	}
	if !active {
		return nil, errors.New("This account has been deactivated.")
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
