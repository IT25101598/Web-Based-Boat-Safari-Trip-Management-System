<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Vessel Specification | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container">
        <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">${vessel.id != null ? 'Edit Vessel Specifications' : 'Register New Fleet Vessel'}</h1>
        <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Configure vessel specifications, engine setups, safety certifications, and passenger capacities.</p>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container" style="max-width: 760px;">
        <div class="card">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/boats" method="POST">
                    <input type="hidden" name="csrf_token" value="${csrfToken}">
                    <c:if test="${vessel.id != null}">
                        <input type="hidden" name="id" value="${vessel.id}">
                    </c:if>

                    <div class="form-group">
                        <label class="form-label">Vessel Commercial Name</label>
                        <input type="text" name="name" value="${vessel.name}" class="form-control" required placeholder="e.g. Ocean Pearl (Ceycat 55)">
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div class="form-group">
                            <label class="form-label">Official Registration Number</label>
                            <input type="text" name="registrationNo" value="${vessel.registrationNo}" class="form-control" required placeholder="e.g. SLC-CAT-001">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Vessel Architecture Type</label>
                            <select name="vesselType" class="form-control">
                                <c:forEach var="vt" items="${vesselTypes}">
                                    <option value="${vt.name()}" ${vessel.vesselType == vt ? 'selected' : ''}>${vt.displayName}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px;">
                        <div class="form-group">
                            <label class="form-label">Passenger Capacity</label>
                            <input type="number" name="capacity" value="${vessel != null ? vessel.capacity.maxPassengers : 20}" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Cabins Count</label>
                            <input type="number" name="cabins" value="${vessel != null ? vessel.capacity.cabins : 2}" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Cruising Speed (Knots)</label>
                            <input type="number" step="0.5" name="cruisingSpeedKnots" value="${vessel.cruisingSpeedKnots > 0 ? vessel.cruisingSpeedKnots : 10.0}" class="form-control" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Engine Propulsion Specs</label>
                        <input type="text" name="engines" value="${vessel.engines}" class="form-control" placeholder="e.g. Twin 75HP Yanmar Marine Diesel">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Safety & SOLAS Life Saving Gear</label>
                        <textarea name="safetyEquipmentNotes" class="form-control" rows="3" placeholder="Life jackets count, life rafts, EPIRB, VHF radios">${vessel.safetyEquipmentNotes}</textarea>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px;">
                        <a href="${pageContext.request.contextPath}/admin/boats" class="btn btn-outline-navy">Cancel</a>
                        <button type="submit" class="btn btn-gold">
                            <i class="fa-solid fa-floppy-disk"></i> Save Vessel Specifications
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
