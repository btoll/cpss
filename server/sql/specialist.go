package sql

import (
	mysql "database/sql"

	"github.com/btoll/cpss/server/app"
)

type Specialist struct {
	Stmt map[string]string
}

func NewSpecialist() *Specialist {
	return &Specialist{
		Stmt: map[string]string{
			"COUNT":  "SELECT COUNT(*) FROM specialist",
			"INSERT": "INSERT specialist SET username=?,password=?,firstname=?,lastname=?,email=?,payrate=?",
			"SELECT": "SELECT * FROM specialist",
		},
	}
}

func (s *Specialist) Create(db *mysql.DB, payload *app.SpecialistPayload) (int64, error) {
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := exec(stmt, payload)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return id, err
}

func (s *Specialist) List(db *mysql.DB) (*app.SpecialistMediaCollection, error) {
	rows, err := db.Query(s.Stmt["COUNT"])
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
	rows, err = db.Query(s.Stmt["SELECT"])
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
	return &collection, nil
}
