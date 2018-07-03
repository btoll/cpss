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
			"DELETE":               "DELETE FROM consumer WHERE id=?",
			"DELETE_SERVICE_CODE":  "DELETE FROM unit_block WHERE id=?",
			"INSERT":               "INSERT consumer SET firstname=?,lastname=?,active=?,county=?,fundingSource=?,zip=?,bsu=?,recipientID=?,dia=?,other=?",
			"INSERT_SERVICE_CODES": "INSERT unit_block SET consumer=?,serviceCode=?,units=?",
			"SELECT":               "SELECT %s FROM consumer %s",
			"SELECT_SERVICE_CODES": "SELECT %s FROM consumer INNER JOIN unit_block ON unit_block.consumer = consumer.id INNER JOIN service_code ON service_code.id = unit_block.serviceCode %s",
			"UPDATE":               "UPDATE consumer SET firstname=?,lastname=?,active=?,county=?,fundingSource=?,zip=?,bsu=?,recipientID=?,dia=?,other=? WHERE id=?",
			"UPDATE_SERVICE_CODES": "UPDATE unit_block SET serviceCode=?,units=? WHERE id=?",
		},
	}
}

func (s *Consumer) GetServiceCodes(db *mysql.DB, id int) ([]*app.UnitBlockItem, error) {
	whereClause := fmt.Sprintf("WHERE consumer.id = %d", id)
	i := 0
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT_SERVICE_CODES"], "COUNT(*)", whereClause))
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT_SERVICE_CODES"], "unit_block.id, service_code.id, unit_block.units", whereClause))
	if err != nil {
		return nil, err
	}
	coll := make([]*app.UnitBlockItem, count)
	for rows.Next() {
		var id int
		var serviceCode int
		var units float64
		err := rows.Scan(&id, &serviceCode, &units)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.UnitBlockItem{
			ID:          id,
			ServiceCode: serviceCode,
			Units:       units,
		}
		i++
	}
	return coll, nil
}

func (s *Consumer) SetServiceCodes(db *mysql.DB, consumer int, serviceCodes []*app.UnitBlockItem) ([]*app.UnitBlockItem, error) {
	updateStmt, err := db.Prepare(s.Stmt["UPDATE_SERVICE_CODES"])
	if err != nil {
		return nil, err
	}
	insertStmt, err := db.Prepare(s.Stmt["INSERT_SERVICE_CODES"])
	if err != nil {
		return nil, err
	}
	deleteStmt, err := db.Prepare(s.Stmt["DELETE_SERVICE_CODE"])
	if err != nil {
		return nil, err
	}
	var serviceCode *app.UnitBlockItem
	coll := []*app.UnitBlockItem{}
	for i := 0; i < len(serviceCodes); i++ {
		serviceCode = serviceCodes[i]
		if serviceCode.ID == -1 {
			res, err := insertStmt.Exec(consumer, serviceCode.ServiceCode, serviceCode.Units)
			if err != nil {
				return nil, err
			}
			id, err := res.LastInsertId()
			if err != nil {
				return nil, err
			}
			serviceCode.ID = int(id)
			coll = append(coll, serviceCode)
		} else if serviceCode.ID < -1 {
			// For an explanation of why we bitwise NOT the id,
			// see https://github.com/btoll/cpss/blob/master/client/src/Page/Consumer.elm.
			_, err := deleteStmt.Exec(^serviceCode.ID)
			if err != nil {
				return nil, err
			}
			// Note we're not adding these to the returned collection!
		} else {
			_, err = updateStmt.Exec(serviceCode.ServiceCode, serviceCode.Units, serviceCode.ID)
			if err != nil {
				return nil, err
			}
			coll = append(coll, serviceCode)
		}
	}
	return coll, nil
}

func (s *Consumer) CollectRows(db *mysql.DB, rows *mysql.Rows, coll []*app.ConsumerItem) error {
	i := 0
	for rows.Next() {
		var id int
		var firstname string
		var lastname string
		var active bool
		var county int
		var fundingSource int
		var zip string
		var bsu string
		var recipientID string
		var dia int
		var other string
		var fullname string
		err := rows.Scan(&id, &firstname, &lastname, &active, &county, &fundingSource, &zip, &bsu, &recipientID, &dia, &other, &fullname)
		if err != nil {
			return err
		}
		// First, get the Service Codes (inner joining consumer, service_code and unit_block tables).
		serviceCodes, err := s.GetServiceCodes(db, id)
		if err != nil {
			return err
		}
		coll[i] = &app.ConsumerItem{
			ID:            id,
			Firstname:     firstname,
			Lastname:      lastname,
			Active:        active,
			County:        county,
			ServiceCodes:  serviceCodes,
			FundingSource: fundingSource,
			Zip:           zip,
			Bsu:           bsu,
			RecipientID:   recipientID,
			Dia:           dia,
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
	res, err := stmt.Exec(payload.Firstname, payload.Lastname, payload.Active, payload.County, payload.FundingSource, payload.Zip, payload.Bsu, payload.RecipientID, payload.Dia, payload.Other)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	// If setting the service codes fails, abort everything!
	_, err = s.SetServiceCodes(db, int(id), payload.ServiceCodes)
	if err != nil {
		return -1, err
	}
	return int(id), nil
}

func (s *Consumer) Update(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.ConsumerPayload)
	// If setting the service codes fails, abort everything!
	serviceCodes, err := s.SetServiceCodes(db, *payload.ID, payload.ServiceCodes)
	if err != nil {
		return -1, err
	}
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}
	_, err = stmt.Exec(payload.Firstname, payload.Lastname, payload.Active, payload.County, payload.FundingSource, payload.Zip, payload.Bsu, payload.RecipientID, payload.Dia, payload.Other, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.ConsumerMedia{
		ID:            *payload.ID,
		Firstname:     payload.Firstname,
		Lastname:      payload.Lastname,
		Active:        payload.Active,
		County:        payload.County,
		ServiceCodes:  serviceCodes,
		FundingSource: payload.FundingSource,
		Zip:           payload.Zip,
		Bsu:           payload.Bsu,
		RecipientID:   payload.RecipientID,
		Dia:           payload.Dia,
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*, CONCAT(lastname,', ',firstname) AS fullname", "ORDER BY fullname ASC"))
	if err != nil {
		return nil, err
	}
	coll := make([]*app.ConsumerItem, count)
	err = s.CollectRows(db, rows, coll)
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*, CONCAT(lastname,', ',firstname) AS fullname", fmt.Sprintf("%s ORDER BY fullname ASC LIMIT %d,%d", whereClause, limit, RecordsPerPage)))
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
	err = s.CollectRows(db, rows, paging.Consumers)
	if err != nil {
		return nil, err
	}
	return paging, nil
}
