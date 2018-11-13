package sql

import (
	mysql "database/sql"
	"fmt"

	"github.com/btoll/cpss/server/app"
)

type ServiceCode struct {
	Data interface{}
	Stmt map[string]string
}

func NewServiceCode(payload interface{}) *ServiceCode {
	return &ServiceCode{
		Data: payload,
		Stmt: map[string]string{
			"DELETE": "DELETE FROM service_code WHERE id=?",
			"INSERT": "INSERT service_code SET name=?,unitRate=?,description=?",
			"SELECT": "SELECT %s FROM service_code ORDER BY name DESC",
			"UPDATE": "UPDATE service_code SET name=?,unitRate=?,description=? WHERE id=?",
		},
	}
}

func (s *ServiceCode) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.ServiceCodePayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Name, payload.UnitRate, payload.Description)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return &app.ServiceCodeMedia{
		ID:          int(id),
		Name:        payload.Name,
		UnitRate:    payload.UnitRate,
		Description: payload.Description,
	}, nil
}

func (s *ServiceCode) Update(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.ServiceCodePayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}

	_, err = stmt.Exec(payload.Name, payload.UnitRate, payload.Description, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.ServiceCodeMedia{
		ID:          *payload.ID,
		Name:        payload.Name,
		UnitRate:    payload.UnitRate,
		Description: payload.Description,
	}, nil
}

func (s *ServiceCode) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := s.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (s *ServiceCode) List(db *mysql.DB) (interface{}, error) {
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
	coll := make(app.ServiceCodeMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var name string
		var unitRate float64
		var description string
		err = rows.Scan(&id, &name, &unitRate, &description)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.ServiceCodeMedia{
			ID:          id,
			Name:        name,
			UnitRate:    unitRate,
			Description: description,
		}
		i++
	}
	return coll, nil
}
