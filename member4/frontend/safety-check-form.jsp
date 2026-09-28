<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../layouts/header.jsp">
    <jsp:param name="title" value="${empty log.id ? 'Pre-Trip Safety Inspection' : 'Amend Pre-Trip Safety Check'}" />
</jsp:include>

<div class="container" style="padding: 40px 20px; max-width: 900px;">
    <!-- Breadcrumb & Header -->
    <div style="margin-bottom: 25px;">
        <a href="${pageContext.request.contextPath}/safety-checks" style="color: var(--gold-primary); font-size: 13.5px; font-weight: 600; text-decoration: none;">
            <i class="fa-solid fa-arrow-left"></i> Back to Safety Check Logs
        </a>
        <h1 style="font-size: 28px; font-weight: 700; color: var(--navy-dark); margin: 10px 0 5px 0;">
            <c:choose>
                <c:when test="${not empty log.id}">
                    <i class="fa-solid fa-pen-to-square" style="color: var(--gold-primary);"></i> Amend Pre-Trip Safety Check #${log.id}
                </c:when>
                <c:otherwise>
                    <i class="fa-solid fa-clipboard-check" style="color: var(--gold-primary);"></i> Captain Pre-Trip Safety Inspection & Clearance
                </c:otherwise>
            </c:choose>
        </h1>
        <p style="color: var(--text-muted); font-size: 14.5px; margin: 0;">
            Mandatory Merchant Shipping Secretariat inspection checklist. Verify all life-saving equipment, fuel reserves, and meteorological conditions.
        </p>
    </div>

    <!-- Error / Flash Alerts -->
    <c:if test="${not empty flashError}">
        <div class="alert alert-danger" style="margin-bottom: 25px;">
            <i class="fa-solid fa-triangle-exclamation"></i> ${flashError}
        </div>
    </c:if>

    <!-- Inspection Checklist Form Card -->
    <div class="card" style="padding: 35px; box-shadow: var(--shadow-md);">
        <form method="POST" action="${pageContext.request.contextPath}${empty log.id ? '/safety-checks/create' : '/safety-checks/edit'}">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <c:if test="${not empty log.id}">
                <input type="hidden" name="id" value="${log.id}">
            </c:if>

            <!-- 1. Assignment Details -->
            <div style="margin-bottom: 30px;">
                <h3 style="font-size: 16px; font-weight: 700; color: var(--navy-dark); border-bottom: 2px solid var(--gold-light); padding-bottom: 8px; margin-bottom: 20px;">
                    <i class="fa-solid fa-ship" style="color: var(--gold-primary);"></i> 1. Assigned Departure & Vessel
                </h3>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div class="form-group">
                        <label class="form-label">Scheduled Safari Departure <span style="color: red;">*</span></label>
                        <select name="scheduleId" id="scheduleSelect" class="form-control" required onchange="autoSelectVessel(this)">
                            <option value="">-- Select Departure --</option>
                            <c:forEach var="sch" items="${schedules}">
                                <option value="${sch.id}" data-vessel="${sch.vesselId}" ${ (log.scheduleId == sch.id || selectedScheduleId == sch.id) ? 'selected' : '' }>
                                    Schedule #${sch.id} - ${sch.tourTitle} (${sch.formattedDepartureTime})
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Inspected Vessel <span style="color: red;">*</span></label>
                        <select name="vesselId" id="vesselSelect" class="form-control" required>
                            <option value="">-- Select Vessel --</option>
                            <c:forEach var="v" items="${vessels}">
                                <option value="${v.id}" ${log.vesselId == v.id ? 'selected' : ''}>
                                    ${v.name} (${v.registrationNo} - ${v.vesselType})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
            </div>

            <!-- 2. Equipment & SOLAS Checklist -->
            <div style="margin-bottom: 30px;">
                <h3 style="font-size: 16px; font-weight: 700; color: var(--navy-dark); border-bottom: 2px solid var(--gold-light); padding-bottom: 8px; margin-bottom: 20px;">
                    <i class="fa-solid fa-shield-halved" style="color: var(--gold-primary);"></i> 2. SOLAS Mandatory Safety Verification
                </h3>

                <div style="background: #F8FAFC; border: 1px solid var(--border-color); border-radius: 8px; padding: 20px; margin-bottom: 20px;">
                    <div style="display: flex; align-items: flex-start; gap: 12px; margin-bottom: 15px;">
                        <input type="checkbox" id="safetyItemsVerified" name="safetyItemsVerified" value="true" ${ (empty log.id || log.safetyItemsVerified) ? 'checked' : '' } style="width: 20px; height: 20px; accent-color: var(--gold-primary); margin-top: 3px;" required>
                        <label for="safetyItemsVerified" style="font-size: 14.5px; color: var(--navy-dark); font-weight: 600; cursor: pointer;">
                            I have personally inspected and verified all primary lifesaving apparatus:
                            <div style="font-size: 13px; font-weight: normal; color: var(--text-muted); margin-top: 4px;">
                                • Inflatable SOLAS Life Rafts & Hydrostatic Release Units<br>
                                • Emergency Flares, Parachute Rockets & Smoke Signals (In-Date)<br>
                                • Marine VHF Radios tested on International Distress Channel 16<br>
                                • Automatic Bilge Pumps and Engine Emergency Shutoff Switches<br>
                                • Certified First Aid Medical Kit & Emergency Oxygen Cylinder
                            </div>
                        </label>
                    </div>

                    <div style="display: flex; align-items: flex-start; gap: 12px; margin-bottom: 15px;">
                        <input type="checkbox" id="briefingConfirmed" name="briefingConfirmed" value="true" ${ (empty log.id || log.briefingConfirmed) ? 'checked' : '' } style="width: 20px; height: 20px; accent-color: var(--gold-primary); margin-top: 3px;" required>
                        <label for="briefingConfirmed" style="font-size: 14.5px; color: var(--navy-dark); font-weight: 600; cursor: pointer;">
                            Passenger Safety Protocol Briefing Prepared
                            <div style="font-size: 13px; font-weight: normal; color: var(--text-muted); margin-top: 4px;">
                                Confirmation that crew will conduct mandatory safety demonstration on life jacket donning and muster stations prior to harbor departure.
                            </div>
                        </label>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div class="form-group">
                        <label class="form-label">Count of Verified Life Jackets Onboard <span style="color: red;">*</span></label>
                        <input type="number" name="lifeJacketsCount" class="form-control" min="1" max="150" value="${empty log.lifeJacketsCount ? 35 : log.lifeJacketsCount}" required>
                        <small style="color: var(--text-light);">Must be greater than total booked guest count + crew.</small>
                    </div>

                    <div class="form-group">
                        <label class="form-label">
                            Bunker Fuel Reserve: <strong id="fuelPercentDisplay">${empty log.fuelLevelPercent ? 95 : log.fuelLevelPercent}%</strong>
                            <span style="color: red;">*</span>
                        </label>
                        <input type="range" name="fuelLevelPercent" id="fuelRange" min="25" max="100" step="5" value="${empty log.fuelLevelPercent ? 95 : log.fuelLevelPercent}" class="form-control" style="cursor: pointer;" oninput="document.getElementById('fuelPercentDisplay').innerText = this.value + '%'">
                        <small style="color: var(--text-light);">Minimum 25% reserve required for clearance.</small>
                    </div>
                </div>
            </div>

            <!-- 3. Meteorological Conditions & Notes -->
            <div style="margin-bottom: 30px;">
                <h3 style="font-size: 16px; font-weight: 700; color: var(--navy-dark); border-bottom: 2px solid var(--gold-light); padding-bottom: 8px; margin-bottom: 20px;">
                    <i class="fa-solid fa-cloud-sun" style="color: var(--gold-primary);"></i> 3. Weather Conditions & Observations
                </h3>

                <div class="form-group">
                    <label class="form-label">Sea State & Weather Report <span style="color: red;">*</span></label>
                    <input type="text" name="weatherConditions" class="form-control" required placeholder="e.g., Calm blue waters, wave swell 0.8m, wind 10 knots SW, visibility 12nm" value="${log.weatherConditions}">
                </div>

                <div class="form-group">
                    <label class="form-label">Pre-Departure Observations & Corrective Actions</label>
                    <textarea name="notes" class="form-control" rows="3" placeholder="Record any pre-trip actions, e.g. refueled 150L diesel, inspected starboard impeller, cleared anchor chain...">${log.notes}</textarea>
                </div>
            </div>

            <!-- 4. Declaration & Digital Signature -->
            <div style="margin-bottom: 30px; background: #FFFBF0; border: 1px solid rgba(197, 168, 128, 0.4); border-radius: 8px; padding: 22px;">
                <h3 style="font-size: 16px; font-weight: 700; color: var(--navy-dark); margin-top: 0; margin-bottom: 12px;">
                    <i class="fa-solid fa-signature" style="color: var(--gold-primary);"></i> 4. Captain "All Clear" Clearance & Signature
                </h3>

                <div style="display: flex; align-items: flex-start; gap: 12px; margin-bottom: 18px;">
                    <input type="checkbox" id="allClear" name="allClear" value="true" ${ (empty log.id || log.allClear) ? 'checked' : '' } style="width: 22px; height: 22px; accent-color: var(--gold-primary); margin-top: 2px;" required>
                    <label for="allClear" style="font-size: 14.5px; color: var(--navy-dark); font-weight: 700; cursor: pointer;">
                        OFFICIAL DECLARATION OF SEAWORTHINESS ("ALL CLEAR")
                        <div style="font-size: 13px; font-weight: normal; color: var(--text-muted); margin-top: 4px;">
                            I hereby certify as the licensed Master Mariner / Boat Captain that this vessel has passed all pre-departure safety requirements, is mechanically sound, fully fueled, and cleared for passenger safari departure.
                        </div>
                    </label>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div class="form-group" style="margin-bottom: 0;">
                        <label class="form-label">Master Mariner / Captain Signature <span style="color: red;">*</span></label>
                        <input type="text" name="captainSignature" class="form-control" required placeholder="Type full name as digital signature" value="${empty log.captainSignature ? currentCaptain : log.captainSignature}">
                        <input type="hidden" name="captainId" value="${empty log.captainId ? currentCaptainId : log.captainId}">
                    </div>
                    <div style="display: flex; align-items: flex-end;">
                        <div style="font-size: 12.5px; color: var(--text-muted); padding-bottom: 10px;">
                            <i class="fa-solid fa-lock"></i> Digitally sealed with timestamp and IP audit trail.
                        </div>
                    </div>
                </div>
            </div>

            <!-- Submit Button -->
            <div style="display: flex; justify-content: flex-end; gap: 15px; border-top: 1px solid var(--border-color); padding-top: 20px;">
                <a href="${pageContext.request.contextPath}/safety-checks" class="btn btn-outline-navy">
                    Cancel
                </a>
                <button type="submit" class="btn btn-primary" style="padding: 12px 28px; font-size: 15px;">
                    <i class="fa-solid fa-certificate"></i>
                    <c:choose>
                        <c:when test="${not empty log.id}">
                            Save Amended Safety Log
                        </c:when>
                        <c:otherwise>
                            Submit "All Clear" & Clear for Departure
                        </c:otherwise>
                    </c:choose>
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function autoSelectVessel(selectElem) {
    var selectedOption = selectElem.options[selectElem.selectedIndex];
    var vesselId = selectedOption.getAttribute('data-vessel');
    if (vesselId) {
        var vesselSelect = document.getElementById('vesselSelect');
        for (var i = 0; i < vesselSelect.options.length; i++) {
            if (vesselSelect.options[i].value == vesselId) {
                vesselSelect.selectedIndex = i;
                break;
            }
        }
    }
}
</script>

<jsp:include page="../layouts/footer.jsp" />
