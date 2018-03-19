package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	"github.com/goadesign/goa"
)

// DIAController implements the DIA resource.
type DIAController struct {
	*goa.Controller
}

// NewDIAController creates a DIA controller.
func NewDIAController(service *goa.Service) *DIAController {
	return &DIAController{Controller: service.NewController("DIAController")}
}

// Create runs the create action.
func (c *DIAController) Create(ctx *app.CreateDIAContext) error {
	// DIAController_Create: start_implement

	res, err := sql.Create(sql.NewDIA(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(res.(*app.DIAMedia))

	// DIAController_Create: end_implement
}

// Delete runs the delete action.
func (c *DIAController) Delete(ctx *app.DeleteDIAContext) error {
	// DIAController_Delete: start_implement

	err := sql.Delete(sql.NewDIA(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.DIAMediaTiny{ctx.ID})

	// DIAController_Delete: end_implement
}

// List runs the list action.
func (c *DIAController) List(ctx *app.ListDIAContext) error {
	// DIAController_List: start_implement

	collection, err := sql.List(sql.NewDIA(nil))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.DIAMediaCollection))

	// DIAController_List: end_implement
}

// Page runs the page action.
func (c *DIAController) Page(ctx *app.PageDIAContext) error {
	// DIAController_Page: start_implement

	collection, err := sql.Page(sql.NewDIA(ctx.Page))
	if err != nil {
		return err
	}
	return ctx.OKPaging(collection.(*app.DIAMediaPaging))

	// DIAController_Page: end_implement
}

// Update runs the update action.
func (c *DIAController) Update(ctx *app.UpdateDIAContext) error {
	// DIAController_Update: start_implement

	rec, err := sql.Update(sql.NewDIA(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.DIAMedia))

	// DIAController_Update: end_implement
}
