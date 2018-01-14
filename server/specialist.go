package main

import (
	mysql "database/sql"

	"github.com/btoll/cpss/server/app"
	_ "github.com/go-sql-driver/mysql"
	"github.com/goadesign/goa"
)

// SpecialistController implements the Specialist resource.
type SpecialistController struct {
	*goa.Controller
}

// NewSpecialistController creates a Specialist controller.
func NewSpecialistController(service *goa.Service) *SpecialistController {
	return &SpecialistController{Controller: service.NewController("SpecialistController")}
}

// Create runs the create action.
func (c *SpecialistController) Create(ctx *app.CreateSpecialistContext) error {
	// SpecialistController_Create: start_implement

	payload := ctx.Payload
	db, err := mysql.Open("mysql", "derp:12345@/herp?charset=utf8")
	if err != nil {
		panic(err)
	}
	stmt, err := db.Prepare("INSERT specialist SET username=?,password=?,firstname=?,lastname=?,email=?,payrate=?")
	if err != nil {
		panic(err)
	}
	r, err := stmt.Exec(payload.Username, payload.Password, payload.Firstname, payload.Lastname, payload.Email, payload.Payrate)
	if err != nil {
		panic(err)
	}
	id, err := r.LastInsertId()
	if err != nil {
		panic(err)
	}
	res := &app.SpecialistMediaTiny{int(id)}
	return ctx.OKTiny(res)
	// SpecialistController_Create: end_implement
}

// Delete runs the delete action.
func (c *SpecialistController) Delete(ctx *app.DeleteSpecialistContext) error {
	// SpecialistController_Delete: start_implement

	// Put your logic here

	// SpecialistController_Delete: end_implement
	return nil
}

// List runs the list action.
func (c *SpecialistController) List(ctx *app.ListSpecialistContext) error {
	// SpecialistController_List: start_implement

	db, err := mysql.Open("mysql", "derp:12345@/herp?charset=utf8")
	if err != nil {
		panic(err)
	}
	rows, err := db.Query("SELECT COUNT(*) FROM specialist")
	if err != nil {
		panic(err)
	}
	var count int
	for rows.Next() {
		err = rows.Scan(&count)
		if err != nil {
			panic(err)
		}
	}
	rows, err = db.Query("SELECT * FROM specialist")
	if err != nil {
		panic(err)
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
			panic(err)
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
	return ctx.OK(collection)

	// SpecialistController_List: end_implement
}
