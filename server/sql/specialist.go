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
			"INSERT": "INSERT specialist SET username=?,password=?,firstname=?,lastname=?,email=?,payrate=?",
			"SELECT": "SELECT %s FROM specialist",
			"UPDATE": "UPDATE specialist SET username=?,password=?,firstname=?,lastname=?,email=?,payrate=? WHERE id=?",
		},
	}
}

func (s *Specialist) Create(db *mysql.DB) (int64, error) {
	payload := s.Data.(*app.SpecialistPayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Username, payload.Password, payload.Firstname, payload.Lastname, payload.Email, payload.Payrate)
	if err != nil {
		return -1, err
	}
	return res.LastInsertId()
}

func (s *Specialist) Update(db *mysql.DB) error {
	payload := s.Data.(*app.SpecialistPayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return err
	}
	_, err = stmt.Exec(payload.Username, payload.Password, payload.Firstname, payload.Lastname, payload.Email, payload.Payrate, payload.ID)
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
