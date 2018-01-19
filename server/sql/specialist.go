package sql

import (
	"crypto/sha256"
	mysql "database/sql"
	"fmt"

	"github.com/btoll/cpss/server/app"
)

type Specialist struct {
	Data interface{}
	Stmt map[string]string
}

func NewSpecialist(payload interface{}) *Specialist {
	return &Specialist{
		Data: payload,
		Stmt: map[string]string{
			"DELETE": "DELETE FROM specialist WHERE id=?",
			"INSERT": "INSERT specialist SET username=?,password=?,firstname=?,lastname=?,email=?,payrate=?",
			"SELECT": "SELECT %s FROM specialist",
			"UPDATE": "UPDATE specialist SET username=?,password=?,firstname=?,lastname=?,email=?,payrate=? WHERE id=?",
			"VERIFY": "SELECT password FROM specialist WHERE id=?",
		},
	}
}

func (s *Specialist) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.SpecialistPayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	hashed := s.Hash(payload.Password)
	res, err := stmt.Exec(payload.Username, hashed, payload.Firstname, payload.Lastname, payload.Email, payload.Payrate)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		panic(err)
	}
	return &app.SpecialistMedia{
		ID:        int(id),
		Username:  payload.Username,
		Password:  hashed,
		Firstname: payload.Firstname,
		Lastname:  payload.Lastname,
		Email:     payload.Email,
		Payrate:   payload.Payrate,
	}, nil
}

func (s *Specialist) Update(db *mysql.DB) error {
	payload := s.Data.(*app.SpecialistPayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return err
	}
	//	_, err = stmt.Exec(payload.Username, hashPassword(payload.Password), payload.Firstname, payload.Lastname, payload.Email, payload.Payrate, payload.ID)
	// Note that we don't want to update the password here.  That will be done in its own view.
	_, err = stmt.Exec(payload.Username, payload.Firstname, payload.Lastname, payload.Email, payload.Payrate, payload.ID)
	return err
}

func (s *Specialist) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := s.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (s *Specialist) List(db *mysql.DB) (interface{}, error) {
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)"))
	if err != nil {
		return nil, err
	}
	var count int
	for rows.Next() {
		err = rows.Scan(&count)
		if err != nil {
			return nil, err
		}
	}
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*"))
	if err != nil {
		return nil, err
	}
	collection := make(app.SpecialistMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var username string
		var password string
		var firstname string
		var lastname string
		var email string
		var payrate float64
		err = rows.Scan(&id, &username, &password, &firstname, &lastname, &email, &payrate)
		if err != nil {
			return nil, err
		}
		collection[i] = &app.SpecialistMedia{
			ID:        id,
			Username:  username,
			Password:  password,
			Firstname: firstname,
			Lastname:  lastname,
			Email:     email,
			Payrate:   payrate,
		}
		i++
	}
	return collection, nil
}

func (s *Specialist) Hash(clearText string) string {
	h := sha256.New()
	h.Write([]byte(clearText))
	// %x -> base 16, with lower-case letters for a-f
	return fmt.Sprintf("%x", h.Sum(nil))
}

func (s *Specialist) Verify(clearText string) (bool, error) {
	db, err := connect()
	if err != nil {
		return false, err
	}
	rows, err := db.Query(s.Stmt["VERIFY"])
	if err != nil {
		return false, err
	}
	var count int
	for rows.Next() {
		err = rows.Scan(&count)
		if err != nil {
			return false, err
		}
	}
	if count == 0 {
		return false, nil
		//	} else {
		//        s.Hash() == s.Hash
	}
	data := s.Data.(*app.SpecialistPayload)
	return s.Hash(data.Password) == s.Hash(clearText), nil
}
