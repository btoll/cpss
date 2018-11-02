package sql

import (
	mysql "database/sql"
	"fmt"
	"math"

	"github.com/btoll/cpss/server/app"
)

type County struct {
	Data interface{}
	Stmt map[string]string
}

func NewCounty(payload interface{}) *County {
	return &County{
		Data: payload,
		Stmt: map[string]string{
			"DELETE":       "DELETE FROM county WHERE id=?",
			"INSERT":       "INSERT county SET name=?,zip=?,county_id=?,state=?",
			"SELECT":       "SELECT %s FROM county ORDER BY name %s",
			"GET_COUNTIES": "SELECT %s FROM county WHERE county_id=%d",
			"UPDATE":       "UPDATE county SET name=?,zip=?,county_id=?,state=? WHERE id=?",
		},
	}
}

func (c *County) Create(db *mysql.DB) (interface{}, error) {
	payload := c.Data.(*app.CountyPayload)
	stmt, err := db.Prepare(c.Stmt["INSERT"])
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
	return int(id), nil
}

func (c *County) Read(db *mysql.DB) (interface{}, error) {
	countyID := c.Data.(int)
	rows, err := db.Query(fmt.Sprintf(c.Stmt["GET_COUNTIES"], "COUNT(id)", countyID))
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
	rows, err = db.Query(fmt.Sprintf(c.Stmt["GET_COUNTIES"], "*", countyID))
	if err != nil {
		return nil, err
	}
	coll := make(app.CountyMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var name string
		var zip string
		var county int
		var state string
		err := rows.Scan(&id, &name, &zip, &county, &state)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.CountyMedia{
			ID:   id,
			Name: name,
		}
		i++
	}
	return coll, nil
}

func (c *County) Update(db *mysql.DB) (interface{}, error) {
	payload := c.Data.(*app.CountyPayload)
	stmt, err := db.Prepare(c.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}
	_, err = stmt.Exec(payload.Name, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.CountyMedia{
		ID:   *payload.ID,
		Name: payload.Name,
	}, nil
}

func (c *County) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(c.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := c.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (c *County) List(db *mysql.DB) (interface{}, error) {
	rows, err := db.Query(fmt.Sprintf(c.Stmt["SELECT"], "COUNT(*)", ""))
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
	rows, err = db.Query(fmt.Sprintf(c.Stmt["SELECT"], "*", ""))
	if err != nil {
		return nil, err
	}
	coll := make(app.CountyMediaCollection, totalCount)
	i := 0
	for rows.Next() {
		var id int
		var name string
		err := rows.Scan(&id, &name)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.CountyMedia{
			ID:   id,
			Name: name,
		}
		i++
	}
	return coll, nil
}

func (c *County) Page(db *mysql.DB) (interface{}, error) {
	// page * RecordsPerPage = limit
	limit := c.Data.(int) * RecordsPerPage
	rows, err := db.Query(fmt.Sprintf(c.Stmt["SELECT"], "COUNT(*)", ""))
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
	rows, err = db.Query(fmt.Sprintf(c.Stmt["SELECT"], "*", fmt.Sprintf("LIMIT %d,%d", limit, RecordsPerPage)))
	if err != nil {
		return nil, err
	}
	// Only the amount of rows equal to RecordsPerPage unless the last page has been requested
	// (determined by `totalCount - limit`).
	capacity := totalCount - limit
	if capacity >= RecordsPerPage {
		capacity = RecordsPerPage
	}
	paging := &app.CountyMediaPaging{
		Pager: &app.Pager{
			CurrentPage:    limit / RecordsPerPage,
			RecordsPerPage: RecordsPerPage,
			TotalCount:     totalCount,
			TotalPages:     int(math.Ceil(float64(totalCount) / float64(RecordsPerPage))),
		},
		Counties: make([]*app.CountyItem, capacity),
	}
	i := 0
	for rows.Next() {
		var id int
		var name string
		err := rows.Scan(&id, &name)
		if err != nil {
			return nil, err
		}
		paging.Counties[i] = &app.CountyItem{
			ID:   id,
			Name: name,
		}
		i++
	}
	return paging, nil
}
