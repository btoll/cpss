package sql

import (
	mysql "database/sql"
	"fmt"
	"math"

	"github.com/btoll/cpss/server/app"
)

type City struct {
	Data interface{}
	Stmt map[string]string
}

func NewCity(payload interface{}) *City {
	return &City{
		Data: payload,
		Stmt: map[string]string{
			"DELETE":     "DELETE FROM city WHERE id=?",
			"INSERT":     "INSERT city SET name=?,zip=?,county_id=?,state=?",
			"SELECT":     "SELECT %s FROM city ORDER BY name %s",
			"GET_CITIES": "SELECT %s FROM city WHERE county_id=%d",
			"UPDATE":     "UPDATE city SET name=?,zip=?,county_id=?,state=? WHERE id=?",
		},
	}
}

func (c *City) Create(db *mysql.DB) (interface{}, error) {
	payload := c.Data.(*app.CityPayload)
	stmt, err := db.Prepare(c.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Name, payload.Zip, payload.County, payload.State)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return int(id), nil
}

func (c *City) Read(db *mysql.DB) (interface{}, error) {
	cityID := c.Data.(int)
	rows, err := db.Query(fmt.Sprintf(c.Stmt["GET_CITIES"], "COUNT(id)", cityID))
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
	rows, err = db.Query(fmt.Sprintf(c.Stmt["GET_CITIES"], "*", cityID))
	if err != nil {
		return nil, err
	}
	coll := make(app.CityMediaCollection, count)
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
		coll[i] = &app.CityMedia{
			ID:     id,
			Name:   name,
			Zip:    zip,
			County: county,
			State:  state,
		}
		i++
	}
	return coll, nil
}

func (c *City) Update(db *mysql.DB) (interface{}, error) {
	payload := c.Data.(*app.CityPayload)
	stmt, err := db.Prepare(c.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}
	_, err = stmt.Exec(payload.Name, payload.Zip, payload.County, payload.State, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.CityMedia{
		ID:     *payload.ID,
		Name:   payload.Name,
		Zip:    payload.Zip,
		County: payload.County,
		State:  payload.State,
	}, nil
}

func (c *City) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(c.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := c.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (c *City) List(db *mysql.DB) (interface{}, error) {
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
	coll := make(app.CityMediaCollection, totalCount)
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
		coll[i] = &app.CityMedia{
			ID:     id,
			Name:   name,
			Zip:    zip,
			County: county,
			State:  state,
		}
		i++
	}
	return coll, nil
}

func (c *City) Page(db *mysql.DB) (interface{}, error) {
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
	paging := &app.CityMediaPaging{
		Pager: &app.Pager{
			CurrentPage:    limit / RecordsPerPage,
			RecordsPerPage: RecordsPerPage,
			TotalCount:     totalCount,
			TotalPages:     int(math.Ceil(float64(totalCount) / float64(RecordsPerPage))),
		},
		Cities: make([]*app.CityItem, capacity),
	}
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
		paging.Cities[i] = &app.CityItem{
			ID:     id,
			Name:   name,
			Zip:    zip,
			County: county,
			State:  state,
		}
		i++
	}
	return paging, nil
}
