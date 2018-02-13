package sql

import (
	mysql "database/sql"
	"fmt"

	"github.com/btoll/cpss/server/app"
)

type Status struct {
	Data interface{}
	Stmt map[string]string
}

func NewStatus(payload interface{}) *Status {
	return &Status{
		Data: payload,
		Stmt: map[string]string{
			"DELETE": "DELETE FROM status WHERE id=?",
			"INSERT": "INSERT status SET status=?",
			"SELECT": "SELECT %s FROM status",
			"UPDATE": "UPDATE status SET status=? WHERE id=?",
		},
	}
}

func (s *Status) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.StatusPayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Status)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return &app.StatusMedia{
		ID:     int(id),
		Status: payload.Status,
	}, nil
}

func (s *Status) Update(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.StatusPayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}

	_, err = stmt.Exec(payload.Status, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.StatusMedia{
		ID:     *payload.ID,
		Status: payload.Status,
	}, nil
}

func (s *Status) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := s.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (s *Status) List(db *mysql.DB) (interface{}, error) {
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
	coll := make(app.StatusMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var status string
		err = rows.Scan(&id, &status)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.StatusMedia{
			ID:     id,
			Status: status,
		}
		i++
	}
	return coll, nil
}
