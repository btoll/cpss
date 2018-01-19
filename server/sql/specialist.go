package sql

import (
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
			"INSERT": "INSERT specialist SET username=?,password=?,firstname=?,lastname=?,email=?,payrate=?,authLevel=?",
			"SELECT": "SELECT %s FROM specialist",
			"UPDATE": "UPDATE specialist SET username=?,firstname=?,lastname=?,email=?,payrate=?,authLevel=? WHERE id=?",
		},
	}
}

func (s *Specialist) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.SpecialistPayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	hashed := hash(payload.Password)
	res, err := stmt.Exec(payload.Username, hashed, payload.Firstname, payload.Lastname, payload.Email, payload.Payrate, payload.AuthLevel)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return &app.SpecialistMedia{
		ID:        int(id),
		Username:  payload.Username,
		Password:  hashed,
		Firstname: payload.Firstname,
		Lastname:  payload.Lastname,
		Email:     payload.Email,
		Payrate:   payload.Payrate,
		AuthLevel: payload.AuthLevel,
	}, nil
}

func (s *Specialist) Read(db *mysql.DB) (interface{}, error) {
	return nil, nil
}

func (s *Specialist) Update(db *mysql.DB) error {
	payload := s.Data.(*app.SpecialistPayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return err
	}
	//	_, err = stmt.Exec(payload.Username, hashPassword(payload.Password), payload.Firstname, payload.Lastname, payload.Email, payload.Payrate, payload.ID)
	// Note that we don't want to update the password here.  That will be done in its own view.
	_, err = stmt.Exec(payload.Username, payload.Firstname, payload.Lastname, payload.Email, payload.Payrate, payload.AuthLevel, payload.ID)
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
	coll := make(app.SpecialistMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var username string
		var password string
		var firstname string
		var lastname string
		var email string
		var payrate float64
		var authLevel int
		err = rows.Scan(&id, &username, &password, &firstname, &lastname, &email, &payrate, &authLevel)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.SpecialistMedia{
			ID:        id,
			Username:  username,
			Password:  password,
			Firstname: firstname,
			Lastname:  lastname,
			Email:     email,
			Payrate:   payrate,
			AuthLevel: authLevel,
		}
		i++
	}
	return coll, nil
}
