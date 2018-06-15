package sql

import (
	mysql "database/sql"
	"fmt"
	"math"

	"github.com/btoll/cpss/server/app"
)

type Consumer struct {
	Data interface{}
	Stmt map[string]string
}

func NewConsumer(payload interface{}) *Consumer {
	return &Consumer{
		Data: payload,
		Stmt: map[string]string{
			"DELETE": "DELETE FROM consumer WHERE id=?",
			"INSERT": "INSERT consumer SET firstname=?,lastname=?,active=?,county=?,serviceCode=?,fundingSource=?,zip=?,bsu=?,recipientID=?,dia=?,units=?,other=?",
			"SELECT": "SELECT %s FROM consumer %s",
			"UPDATE": "UPDATE consumer SET firstname=?,lastname=?,active=?,county=?,serviceCode=?,fundingSource=?,zip=?,bsu=?,recipientID=?,dia=?,units=?,other=? WHERE id=?",
		},
	}
}

func (s *Consumer) CollectRows(rows *mysql.Rows, coll []*app.ConsumerItem) error {
	i := 0
	for rows.Next() {
		var id int
		var firstname string
		var lastname string
		var active bool
		var county int
		var serviceCode int
		var fundingSource int
		var zip string
		var bsu string
		var recipientID string
		var dia int
		var units float64
		var other string
		err := rows.Scan(&id, &firstname, &lastname, &active, &county, &serviceCode, &fundingSource, &zip, &bsu, &recipientID, &dia, &units, &other)
		if err != nil {
			return err
		}
		coll[i] = &app.ConsumerItem{
			ID:            id,
			Firstname:     firstname,
			Lastname:      lastname,
			Active:        active,
			County:        county,
			ServiceCode:   serviceCode,
			FundingSource: fundingSource,
			Zip:           zip,
			Bsu:           bsu,
			RecipientID:   recipientID,
			Dia:           dia,
			Units:         units,
			Other:         other,
		}
		i++
	}
	return nil
}

func (s *Consumer) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.ConsumerPayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Firstname, payload.Lastname, payload.Active, payload.County, payload.ServiceCode, payload.FundingSource, payload.Zip, payload.Bsu, payload.RecipientID, payload.Dia, payload.Units, payload.Other)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return int(id), nil
}

func (s *Consumer) Update(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.ConsumerPayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}
	_, err = stmt.Exec(payload.Firstname, payload.Lastname, payload.Active, payload.County, payload.ServiceCode, payload.FundingSource, payload.Zip, payload.Bsu, payload.RecipientID, payload.Dia, payload.Units, payload.Other, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.ConsumerMedia{
		ID:            *payload.ID,
		Firstname:     payload.Firstname,
		Lastname:      payload.Lastname,
		Active:        payload.Active,
		County:        payload.County,
		ServiceCode:   payload.ServiceCode,
		FundingSource: payload.FundingSource,
		Zip:           payload.Zip,
		Bsu:           payload.Bsu,
		RecipientID:   payload.RecipientID,
		Dia:           payload.Dia,
		Units:         payload.Units,
		Other:         payload.Other,
	}, nil
}

func (s *Consumer) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := s.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (s *Consumer) List(db *mysql.DB) (interface{}, error) {
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", ""))
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", ""))
	if err != nil {
		return nil, err
	}
	coll := make([]*app.ConsumerItem, count)
	err = s.CollectRows(rows, coll)
	if err != nil {
		return nil, err
	}
	return coll, nil
}

func (s *Consumer) Page(db *mysql.DB) (interface{}, error) {
	query := s.Data.(*PageQuery)
	limit := query.Page * RecordsPerPage
	whereClause := ""
	if query.WhereClause != "" {
		whereClause = fmt.Sprintf("WHERE %s", query.WhereClause)
	}
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", whereClause))
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", fmt.Sprintf("%s LIMIT %d,%d", whereClause, limit, RecordsPerPage)))
	if err != nil {
		return nil, err
	}
	// Only the amount of rows equal to recordsPerPage unless the last page has been requested
	// (determined by `totalCount - limit`).
	capacity := totalCount - limit
	if capacity >= RecordsPerPage {
		capacity = RecordsPerPage
	}
	paging := &app.ConsumerMediaPaging{
		Pager: &app.Pager{
			CurrentPage:    limit / RecordsPerPage,
			RecordsPerPage: RecordsPerPage,
			TotalCount:     totalCount,
			TotalPages:     int(math.Ceil(float64(totalCount) / float64(RecordsPerPage))),
		},
		Consumers: make([]*app.ConsumerItem, capacity),
	}
	err = s.CollectRows(rows, paging.Consumers)
	if err != nil {
		return nil, err
	}
	return paging, nil
}
