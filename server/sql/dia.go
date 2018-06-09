package sql

import (
	mysql "database/sql"
	"fmt"
	"math"

	"github.com/btoll/cpss/server/app"
)

type DIA struct {
	Data interface{}
	Stmt map[string]string
}

func NewDIA(payload interface{}) *DIA {
	return &DIA{
		Data: payload,
		Stmt: map[string]string{
			"DELETE": "DELETE FROM dia WHERE id=?",
			"INSERT": "INSERT dia SET name=?",
			"SELECT": "SELECT %s FROM dia ORDER BY name",
			"UPDATE": "UPDATE dia SET name=? WHERE id=?",
		},
	}
}

func (s *DIA) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.DIAPayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Name)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return &app.DIAMedia{
		ID:   int(id),
		Name: payload.Name,
	}, nil
}

func (s *DIA) Update(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.DIAPayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}

	_, err = stmt.Exec(payload.Name, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.DIAMedia{
		ID:   *payload.ID,
		Name: payload.Name,
	}, nil
}

func (s *DIA) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := s.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (s *DIA) List(db *mysql.DB) (interface{}, error) {
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
	coll := make(app.DIAMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var name string
		err = rows.Scan(&id, &name)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.DIAMedia{
			ID:   id,
			Name: name,
		}
		i++
	}
	return coll, nil
}

func (s *DIA) Page(db *mysql.DB) (interface{}, error) {
	// page * RecordsPerPage = limit
	limit := s.Data.(int) * RecordsPerPage
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", ""))
	if err != nil {
		return nil, err
	}
	var totalCount int
	for rows.Next() {
		err = rows.Scan(&totalCount)
		if err != nil {
			return nil, err
		}
	}
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", fmt.Sprintf("LIMIT %d,%d", limit, RecordsPerPage)))
	if err != nil {
		return nil, err
	}
	// Only the amount of rows equal to RecordsPerPage unless the last page has been requested
	// (determined by `totalCount - limit`).
	capacity := totalCount - limit
	if capacity >= RecordsPerPage {
		capacity = RecordsPerPage
	}
	paging := &app.DIAMediaPaging{
		Pager: &app.Pager{
			CurrentPage:    limit / RecordsPerPage,
			RecordsPerPage: RecordsPerPage,
			TotalCount:     totalCount,
			TotalPages:     int(math.Ceil(float64(totalCount) / float64(RecordsPerPage))),
		},
		Dias: make([]*app.DIAItem, capacity),
	}
	i := 0
	for rows.Next() {
		var id int
		var name string
		err = rows.Scan(&id, &name)
		if err != nil {
			return nil, err
		}
		paging.Dias[i] = &app.DIAItem{
			ID:   id,
			Name: name,
		}
		i++
	}
	return paging, nil
}
