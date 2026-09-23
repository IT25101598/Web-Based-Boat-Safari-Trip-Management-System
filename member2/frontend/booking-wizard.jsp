<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Book Safari Cruise | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 130px 0 40px 0; color: #FFFFFF; text-align: center;">
    <div class="container">
        <h1 style="font-size: 36px; font-weight: 700; color: #FFFFFF; margin: 0 0 8px 0;">Luxury Cruise Reservation Wizard</h1>
        <p style="color: #94A3B8; margin: 0; font-size: 15px;">Reserve your seats, submit the passenger manifest, and apply exclusive promotional discounts.</p>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container" style="max-width: 860px;">
        <div class="card" style="box-shadow: var(--shadow-lg);">
            <div class="card-body" style="padding: 36px;">
                <form action="${pageContext.request.contextPath}/booking/submit" method="POST" id="bookingForm">
                    <input type="hidden" name="csrf_token" value="${csrfToken}">

                    <!-- Step 1: Tour & Departure Selection -->
                    <h3 style="font-size: 18px; color: var(--navy-primary); margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                        <span style="width: 28px; height: 28px; background: var(--navy-primary); color: #fff; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 13px;">1</span>
                        Select Scheduled Cruise Departure
                    </h3>

                    <div class="form-group">
                        <label class="form-label">Choose Departure Schedule</label>
                        <select name="scheduleId" id="scheduleSelect" class="form-control" required onchange="updatePriceCalculation()">
                            <option value="">-- Select an Upcoming Departure --</option>
                            <c:forEach var="s" items="${schedules}">
                                <option value="${s.id}" data-price="${s.tour.basePrice.amount}" ${selectedScheduleId == s.id ? 'selected' : ''}>
                                    ${s.tour.title} — Departs: ${s.formattedDeparture} (${s.availableSeats} seats available)
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group" style="max-width: 250px;">
                        <label class="form-label">Number of Guests</label>
                        <select name="guestCount" id="guestCountSelect" class="form-control" onchange="renderPassengerFields(); updatePriceCalculation();">
                            <option value="1">1 Guest</option>
                            <option value="2" selected>2 Guests</option>
                            <option value="3">3 Guests</option>
                            <option value="4">4 Guests</option>
                            <option value="5">5 Guests</option>
                            <option value="6">6 Guests</option>
                        </select>
                    </div>

                    <hr style="border: none; border-top: 1px solid var(--border-color); margin: 30px 0;">

                    <!-- Step 2: Passenger Manifest -->
                    <h3 style="font-size: 18px; color: var(--navy-primary); margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                        <span style="width: 28px; height: 28px; background: var(--navy-primary); color: #fff; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 13px;">2</span>
                        Maritime Passenger Manifest
                    </h3>
                    <p style="font-size: 13px; color: var(--text-muted); margin-bottom: 18px;">
                        Required by Sri Lanka Merchant Shipping Regulations for all passengers boarding ocean catamarans.
                    </p>

                    <div id="passengerContainer">
                        <!-- Dynamically populated via JS -->
                    </div>

                    <hr style="border: none; border-top: 1px solid var(--border-color); margin: 30px 0;">

                    <!-- Step 3: Promotion & Pricing Summary -->
                    <h3 style="font-size: 18px; color: var(--navy-primary); margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                        <span style="width: 28px; height: 28px; background: var(--navy-primary); color: #fff; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 13px;">3</span>
                        Promotional Discount & Fare Breakdown
                    </h3>

                    <div style="display: flex; gap: 12px; margin-bottom: 20px;">
                        <input type="text" id="promoInput" name="promoCode" class="form-control" placeholder="Enter Promo Code (e.g. SAIL15, EARLYBIRD)" style="text-transform: uppercase;">
                        <button type="button" class="btn btn-outline-navy" onclick="applyPromoCode()">
                            Apply Code
                        </button>
                    </div>
                    <div id="promoMessage" style="font-size: 13.5px; margin-bottom: 18px;"></div>

                    <div class="form-group">
                        <label class="form-label">Special Requests / Dietary Preferences</label>
                        <textarea name="specialNotes" class="form-control" rows="2" placeholder="e.g., Vegetarian meal, celebrating wedding anniversary"></textarea>
                    </div>

                    <!-- Price Box Summary -->
                    <div style="background: #F8FAFD; border: 1px solid var(--border-gold); border-radius: var(--radius-md); padding: 22px; margin-top: 24px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 14.5px;">
                            <span>Subtotal Fare:</span>
                            <span id="subtotalDisplay">LKR 0.00</span>
                        </div>
                        <div style="display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 14.5px; color: var(--success);">
                            <span>Promotional Discount:</span>
                            <span id="discountDisplay">- LKR 0.00</span>
                        </div>
                        <div style="display: flex; justify-content: space-between; font-size: 20px; font-weight: 800; color: var(--navy-primary); border-top: 1px solid #E2E8F0; padding-top: 10px;">
                            <span>Total Payable:</span>
                            <span id="totalDisplay">LKR 0.00</span>
                        </div>
                    </div>

                    <div style="margin-top: 30px; text-align: right;">
                        <button type="submit" class="btn btn-gold btn-lg">
                            <i class="fa-solid fa-lock"></i> Confirm & Issue Boarding Ticket
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<script>
let currentBasePrice = 24500.00;
let currentDiscount = 0.00;

function renderPassengerFields() {
    const count = parseInt(document.getElementById('guestCountSelect').value);
    const container = document.getElementById('passengerContainer');
    container.innerHTML = '';

    for (let i = 1; i <= count; i++) {
        const div = document.createElement('div');
        div.style.cssText = 'background: #FAFCFE; border: 1px solid #E2E8F0; border-radius: 8px; padding: 16px; margin-bottom: 14px;';
        div.innerHTML = `
            <div style="font-weight: 700; color: var(--navy-primary); margin-bottom: 10px; font-size: 14px;">Guest ` + i + ` Details</div>
            <div style="display: grid; grid-template-columns: 2fr 1.5fr 1fr 1fr; gap: 12px;">
                <div>
                    <label style="font-size: 12px; font-weight: 600;">Full Legal Name</label>
                    <input type="text" name="passengerName_` + i + `" class="form-control" required placeholder="Full Name" value="` + (i === 1 ? '${currentUser != null ? currentUser.fullName : "Guest 1"}' : "Guest " + i) + `">
                </div>
                <div>
                    <label style="font-size: 12px; font-weight: 600;">Passport / NIC No</label>
                    <input type="text" name="passengerId_` + i + `" class="form-control" required placeholder="Passport or NIC" value="DOC-0` + i + `">
                </div>
                <div>
                    <label style="font-size: 12px; font-weight: 600;">Age</label>
                    <input type="number" name="passengerAge_` + i + `" class="form-control" value="` + (25 + i * 2) + `" min="1" max="100">
                </div>
                <div>
                    <label style="font-size: 12px; font-weight: 600;">Gender</label>
                    <select name="passengerGender_` + i + `" class="form-control">
                        <option value="MALE">Male</option>
                        <option value="FEMALE">Female</option>
                    </select>
                </div>
            </div>
        `;
        container.appendChild(div);
    }
}

function updatePriceCalculation() {
    const select = document.getElementById('scheduleSelect');
    const selectedOption = select.options[select.selectedIndex];
    if (selectedOption && selectedOption.dataset.price) {
        currentBasePrice = parseFloat(selectedOption.dataset.price);
    }

    const count = parseInt(document.getElementById('guestCountSelect').value);
    const subtotal = currentBasePrice * count;
    const finalTotal = Math.max(0, subtotal - currentDiscount);

    document.getElementById('subtotalDisplay').textContent = 'LKR ' + subtotal.toLocaleString('en-US', { minimumFractionDigits: 2 });
    document.getElementById('discountDisplay').textContent = '- LKR ' + currentDiscount.toLocaleString('en-US', { minimumFractionDigits: 2 });
    document.getElementById('totalDisplay').textContent = 'LKR ' + finalTotal.toLocaleString('en-US', { minimumFractionDigits: 2 });
}

function applyPromoCode() {
    const code = document.getElementById('promoInput').value.trim();
    const count = parseInt(document.getElementById('guestCountSelect').value);
    const subtotal = currentBasePrice * count;
    const msg = document.getElementById('promoMessage');

    if (!code) return;

    validatePromoCode(code, subtotal, (res) => {
        if (res.valid) {
            currentDiscount = res.discountAmount;
            msg.style.color = 'var(--success)';
            msg.innerHTML = '<i class="fa-solid fa-circle-check"></i> ' + res.message + ' (Saved ' + res.discountFormatted + ')';
            updatePriceCalculation();
        } else {
            currentDiscount = 0;
            msg.style.color = 'var(--danger)';
            msg.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> ' + res.message;
            updatePriceCalculation();
        }
    });
}

document.addEventListener('DOMContentLoaded', () => {
    renderPassengerFields();
    updatePriceCalculation();
});
</script>

<jsp:include page="../layouts/footer.jsp" />
