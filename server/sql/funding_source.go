package sql

import (
	mysql "database/sql"
	"fmt"
	"math"

	"github.com/btoll/cpss/server/app"
)

type FundingSource struct {
	Data interface{}
	Stmt map[string]string
}

func NewFundingSource(payload interface{}) *FundingSource {
	return &FundingSource{
		Data: payload,
		Stmt: map[string]string{
			"DELETE": "DELETE FROM funding_source WHERE id=?",
			"INSERT": "INSERT funding_source SET name=?",
			"SELECT": "SELECT %s FROM funding_source ORDER BY name",
			"UPDATE": "UPDATE funding_source SET name=? WHERE id=?",
		},
	}
}

func (s *FundingSource) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.FundingSourcePayload)
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
	return &app.FundingSourceMedia{
		ID:   int(id),
		Name: payload.Name,
	}, nil
}

func (s *FundingSource) Update(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.FundingSourcePayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}

	_, err = stmt.Exec(payload.Name, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.FundingSourceMedia{
		ID:   *payload.ID,
		Name: payload.Name,
	}, nil
}

func (s *FundingSource) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := s.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (s *FundingSource) List(db *mysql.DB) (interface{}, error) {
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
	coll := make(app.FundingSourceMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var name string
		err = rows.Scan(&id, &name)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.FundingSourceMedia{
			ID:   id,
			Name: name,
		}
		i++
	}
	return coll, nil
}

func (s *FundingSource) Page(db *mysql.DB) (interface{}, error) {
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
	paging := &app.FundingSourceMediaPaging{
		Pager: &app.Pager{
			CurrentPage:    limit / RecordsPerPage,
			RecordsPerPage: RecordsPerPage,
			TotalCount:     totalCount,
			TotalPages:     int(math.Ceil(float64(totalCount) / float64(RecordsPerPage))),
		},
		Fundingsources: make([]*app.FundingSourceItem, capacity),
	}
	i := 0
	for rows.Next() {
		var id int
		var name string
		err = rows.Scan(&id, &name)
		if err != nil {
			return nil, err
		}
		paging.Fundingsources[i] = &app.FundingSourceItem{
			ID:   id,
			Name: name,
		}
		i++
	}
	return paging, nil
}
