package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	"github.com/goadesign/goa"
)

// FundingSourceController implements the FundingSource resource.
type FundingSourceController struct {
	*goa.Controller
}

// NewFundingSourceController creates a FundingSource controller.
func NewFundingSourceController(service *goa.Service) *FundingSourceController {
	return &FundingSourceController{Controller: service.NewController("FundingSourceController")}
}

// Create runs the create action.
func (c *FundingSourceController) Create(ctx *app.CreateFundingSourceContext) error {
	// FundingSourceController_Create: start_implement

	res, err := sql.Create(sql.NewFundingSource(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(res.(*app.FundingSourceMedia))

	// FundingSourceController_Create: end_implement
}

// Delete runs the delete action.
func (c *FundingSourceController) Delete(ctx *app.DeleteFundingSourceContext) error {
	// FundingSourceController_Delete: start_implement

	err := sql.Delete(sql.NewFundingSource(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.FundingSourceMediaTiny{ctx.ID})

	// FundingSourceController_Delete: end_implement
}

// List runs the list action.
func (c *FundingSourceController) List(ctx *app.ListFundingSourceContext) error {
	// FundingSourceController_List: start_implement

	collection, err := sql.List(sql.NewFundingSource(nil))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.FundingSourceMediaCollection))

	// FundingSourceController_List: end_implement
}

// Page runs the page action.
func (c *FundingSourceController) Page(ctx *app.PageFundingSourceContext) error {
	// FundingSourceController_Page: start_implement

	collection, err := sql.Page(sql.NewFundingSource(ctx.Page))
	if err != nil {
		return err
	}
	return ctx.OKPaging(collection.(*app.FundingSourceMediaPaging))

	// FundingSourceController_Page: end_implement
}

// Update runs the update action.
func (c *FundingSourceController) Update(ctx *app.UpdateFundingSourceContext) error {
	// FundingSourceController_Update: start_implement

	rec, err := sql.Update(sql.NewFundingSource(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.FundingSourceMedia))

	// FundingSourceController_Update: end_implement
}
