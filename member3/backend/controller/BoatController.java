package com.boatsafari.member3.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.util.Csrf;
import com.boatsafari.member3.model.*;
import com.boatsafari.member3.service.BoatService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

/**
 * Member 3: Boat Fleet Management Controller (Member 3: Boat Fleet Management).
 */
@WebServlet(name = "BoatController", urlPatterns = {"/boats", "/admin/boats", "/admin/boats/create", "/admin/boats/edit", "/admin/boats/status", "/admin/boats/delete"})
public class BoatController extends BaseController {
    private final BoatService boatService = new BoatService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            // ==========================================
            // Member 3: READ (List Vessels)
            // ==========================================
            case "/boats":
            case "/admin/boats":
                List<Vessel> vessels = boatService.getAllVessels();
                request.setAttribute("vessels", vessels);
                request.setAttribute("vesselTypes", VesselType.values());
                request.setAttribute("vesselStatuses", VesselStatus.values());
                render(request, response, "member3/boat-list.jsp");
                break;

            // ==========================================
            // Member 3: CREATE (Show Create Vessel Form)
            // ==========================================
            case "/admin/boats/create":
                request.setAttribute("vesselTypes", VesselType.values());
                render(request, response, "member3/boat-form.jsp");
                break;

            // ==========================================
            // Member 3: UPDATE (Show Edit Vessel Form)
            // ==========================================
            case "/admin/boats/edit":
                int editId = getIntParam(request, "id", 0);
                Optional<Vessel> opt = boatService.getVesselById(editId);
                if (opt.isPresent()) {
                    request.setAttribute("vessel", opt.get());
                    request.setAttribute("vesselTypes", VesselType.values());
                    render(request, response, "member3/boat-form.jsp");
                } else {
                    flashError(request, "Vessel not found.");
                    redirect(response, request.getContextPath() + "/admin/boats");
                }
                break;

            default:
                redirect(response, request.getContextPath() + "/boats");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!Csrf.validate(request)) {
            flashError(request, "Security verification failed.");
            redirect(response, request.getContextPath() + "/admin/boats");
            return;
        }

        String path = request.getServletPath();

        // ==========================================
        // Member 3: UPDATE (Update Vessel Status)
        // ==========================================
        if ("/admin/boats/status".equals(path)) {
            int vesselId = getIntParam(request, "id", 0);
            String statusStr = getStringParam(request, "status", "AVAILABLE");
            String reason = getStringParam(request, "reason", "");
            try {
                VesselStatus newStatus = VesselStatus.valueOf(statusStr);
                var conflicts = boatService.checkVesselScheduleConflicts(vesselId);
                boatService.updateStatus(vesselId, newStatus, reason);

                if (!conflicts.isEmpty() && (newStatus == VesselStatus.UNDER_MAINTENANCE || newStatus == VesselStatus.INACTIVE)) {
                    flashError(request, "Vessel status changed to " + newStatus.getLabel() + 
                        ". CONFLICT ALERT: " + conflicts.size() + " active scheduled departure(s) are assigned to this vessel! Please reassign or notify the captain.");
                } else {
                    flashSuccess(request, "Vessel status updated to " + newStatus.getLabel() + ".");
                }
            } catch (Exception e) {
                flashError(request, "Invalid vessel status.");
            }
            redirect(response, request.getContextPath() + "/admin/boats");
            return;
        }

        // ==========================================
        // Member 3: DELETE (Delete Vessel)
        // ==========================================
        if ("/admin/boats/delete".equals(path)) {
            int deleteId = getIntParam(request, "id", 0);
            boolean deleted = boatService.deleteVessel(deleteId);
            if (deleted) {
                flashSuccess(request, "Vessel #" + deleteId + " and its records were removed from the fleet registry.");
            } else {
                flashError(request, "Unable to delete vessel. It does not exist.");
            }
            redirect(response, request.getContextPath() + "/admin/boats");
            return;
        }

        // ==========================================
        // Member 3: CREATE & UPDATE (Save Vessel)
        // ==========================================
        // Save (Create or Edit)
        int id = getIntParam(request, "id", 0);
        String name = getStringParam(request, "name", "");
        String regNo = getStringParam(request, "registrationNo", "");
        String typeStr = getStringParam(request, "vesselType", "CATAMARAN");
        int capacity = getIntParam(request, "capacity", 20);
        int cabins = getIntParam(request, "cabins", 2);
        String engines = getStringParam(request, "engines", "Twin Marine Diesel");
        double speed = getDoubleParam(request, "cruisingSpeedKnots", 10.0);
        String imageUrl = getStringParam(request, "imageUrl", "assets/img/fleet/ocean-pearl.jpg");
        String safetyNotes = getStringParam(request, "safetyEquipmentNotes", "SOLAS life jackets, life rafts, VHF radio");

        VesselType vType;
        try {
            vType = VesselType.valueOf(typeStr);
        } catch (Exception e) {
            vType = VesselType.CATAMARAN;
        }

        Vessel vessel;
        switch (vType) {
            case YACHT:
                vessel = new Yacht();
                break;
            case SPEEDBOAT:
                vessel = new SpeedBoat();
                break;
            case CATAMARAN:
            default:
                vessel = new Catamaran();
                break;
        }

        if (id > 0) vessel.setId(id);
        vessel.setName(name);
        vessel.setRegistrationNo(regNo);
        vessel.setVesselType(vType);
        vessel.setCapacityValues(capacity, cabins);
        vessel.setEngines(engines);
        vessel.setCruisingSpeedKnots(speed);
        vessel.setImageUrl(imageUrl);
        vessel.setSafetyEquipmentNotes(safetyNotes);

        try {
            boatService.saveVessel(vessel);
            flashSuccess(request, "Vessel successfully recorded in fleet registry!");
            redirect(response, request.getContextPath() + "/admin/boats");
        } catch (ValidationException e) {
            flashError(request, e.getMessage());
            redirect(response, request.getContextPath() + (id > 0 ? "/admin/boats/edit?id=" + id : "/admin/boats/create"));
        }
    }
}
