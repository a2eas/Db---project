import streamlit as st
import pandas as pd
from datetime import date
from db import fetch_all, fetch_one, execute

# ──────────────────────────────────────────────
# Page config
# ──────────────────────────────────────────────
st.set_page_config(page_title="Civil Registry System", layout="wide")
st.title("Civil Registry System")


# ──────────────────────────────────────────────
# Helper: load every detail for one citizen
# ──────────────────────────────────────────────
def get_full_details(citizen_id):
    # Core citizen row
    citizen = fetch_one(
        "SELECT * FROM Citizen WHERE CitizenID = %s",
        (citizen_id,)
    )
    if not citizen:
        return None

    details = dict(citizen)

    # Current address
    address = fetch_one(
        "SELECT * FROM Address WHERE CitizenID = %s AND IsCurrent = TRUE",
        (citizen_id,)
    )
    if address:
        details.update(dict(address))

    # ID card
    card = fetch_one(
        "SELECT * FROM NationalIDCard WHERE CitizenID = %s",
        (citizen_id,)
    )
    if card:
        details.update(dict(card))

    # Birth record
    birth = fetch_one(
        "SELECT * FROM BirthRecord WHERE CitizenID = %s",
        (citizen_id,)
    )
    if birth:
        details.update(dict(birth))

    # Death record
    death = fetch_one(
        "SELECT * FROM DeathRecord WHERE CitizenID = %s",
        (citizen_id,)
    )
    if death:
        details["DeathRecord"] = dict(death)

    # Family membership
    family_rows = fetch_all(
        """
        SELECT f.FamilyID, f.FamilyName, f.HeadCitizenID, fm.Relationship
        FROM   FamilyMember fm
        JOIN   Family f ON fm.FamilyID = f.FamilyID
        WHERE  fm.CitizenID = %s
        """,
        (citizen_id,)
    )
    if family_rows:
        details["FamilyMemberships"] = [dict(r) for r in family_rows]

    # Marriage (as husband)
    marriage_h = fetch_one(
        "SELECT * FROM MarriageRecord WHERE HusbandID = %s",
        (citizen_id,)
    )
    if marriage_h:
        details["MarriageAsHusband"] = dict(marriage_h)

    # Marriage (as wife)
    marriage_w = fetch_one(
        "SELECT * FROM MarriageRecord WHERE WifeID = %s",
        (citizen_id,)
    )
    if marriage_w:
        details["MarriageAsWife"] = dict(marriage_w)

    return details


# ──────────────────────────────────────────────
# Helper: render full detail card
# ──────────────────────────────────────────────
def display_full_details(details, title):
    st.subheader(title)

    col1, col2 = st.columns(2)

    with col1:
        st.markdown("**Personal Information**")
        for field in ["CitizenID", "NationalID", "FirstName", "LastName",
                      "Gender", "DateOfBirth", "PlaceOfBirth", "BloodType",
                      "Religion", "MaritalStatus", "Occupation",
                      "PhoneNumber", "Email"]:
            if details.get(field) is not None:
                st.write(f"{field}: {details[field]}")

        st.markdown("**Address**")
        for field in ["Governorate", "City", "District",
                      "Street", "BuildingNumber", "PostalCode"]:
            if details.get(field) is not None:
                st.write(f"{field}: {details[field]}")

    with col2:
        st.markdown("**National ID Card**")
        for field in ["CardID", "IssueDate", "ExpiryDate", "CardStatus"]:
            if details.get(field) is not None:
                st.write(f"{field}: {details[field]}")

        st.markdown("**Birth Record**")
        for field in ["BirthRecordID", "RegistrationDate",
                      "HospitalName", "DoctorName", "FatherID", "MotherID"]:
            if details.get(field) is not None:
                st.write(f"{field}: {details[field]}")

        st.markdown("**Death Record**")
        if details.get("DeathRecord"):
            d = details["DeathRecord"]
            st.write(f"Death Date: {d.get('DeathDate')}")
            st.write(f"Cause: {d.get('CauseOfDeath')}")
            st.write(f"Place: {d.get('PlaceOfDeath')}")
            st.write(f"Certificate No: {d.get('CertificateNo')}")
        else:
            st.write("No death record.")

        st.markdown("**Family**")
        memberships = details.get("FamilyMemberships")
        if memberships:
            for fam in memberships:
                st.write(f"Family: {fam['FamilyName']} | "
                         f"Role: {fam['Relationship']} | "
                         f"Head CitizenID: {fam['HeadCitizenID']}")
        else:
            st.write("Not assigned to any family.")

        st.markdown("**Marriage**")
        if details.get("MarriageAsHusband"):
            m = details["MarriageAsHusband"]
            st.write(f"MarriageID: {m['MarriageID']}")
            st.write(f"WifeID: {m['WifeID']}")
            st.write(f"Marriage Date: {m['MarriageDate']}")
            st.write(f"Location: {m['MarriageLocation']}")
            st.write(f"Certificate No: {m['CertificateNo']}")
        elif details.get("MarriageAsWife"):
            m = details["MarriageAsWife"]
            st.write(f"MarriageID: {m['MarriageID']}")
            st.write(f"HusbandID: {m['HusbandID']}")
            st.write(f"Marriage Date: {m['MarriageDate']}")
            st.write(f"Location: {m['MarriageLocation']}")
            st.write(f"Certificate No: {m['CertificateNo']}")
        else:
            st.write("No marriage record found.")

    st.markdown("---")


# ──────────────────────────────────────────────
# Sidebar navigation
# ──────────────────────────────────────────────
option = st.sidebar.radio(
    "Navigation",
    ["View Citizens", "Add Citizen", "Search Citizen"]
)

# ──────────────────────────────────────────────
# 1. View Citizens
# ──────────────────────────────────────────────
if option == "View Citizens":
    st.header("List of Citizens")

    rows = fetch_all(
        "SELECT CitizenID, NationalID, FirstName, LastName FROM Citizen ORDER BY CitizenID"
    )

    if not rows:
        st.info("No citizens found in the database.")
    else:
        # Track which citizen is selected
        if "selected_citizen" not in st.session_state:
            st.session_state.selected_citizen = None

        for row in rows:
            col1, col2, col3, col4 = st.columns([1, 2, 2, 1])
            with col1:
                st.write(row["citizenid"])
            with col2:
                st.write(row["nationalid"])
            with col3:
                st.write(f"{row['firstname']} {row['lastname']}")
            with col4:
                if st.button("Show Details", key=f"btn_{row['citizenid']}"):
                    st.session_state.selected_citizen = row["citizenid"]

        if st.session_state.selected_citizen:
            details = get_full_details(st.session_state.selected_citizen)
            if details:
                full_name = f"{details.get('firstname','')} {details.get('lastname','')}"
                display_full_details(details, f"Full Details — {full_name}")
            if st.button("Clear Selection"):
                st.session_state.selected_citizen = None
                st.rerun()

# ──────────────────────────────────────────────
# 2. Add Citizen
# ──────────────────────────────────────────────
elif option == "Add Citizen":
    st.header("Add New Citizen")

    with st.form("add_citizen_form"):
        # ── Personal info ──────────────────────
        col1, col2 = st.columns(2)
        with col1:
            national_id    = st.text_input("National ID *")
            first_name     = st.text_input("First Name *")
            last_name      = st.text_input("Last Name *")
            gender         = st.selectbox("Gender", ["M", "F"])
            dob            = st.date_input("Date of Birth", max_value=date.today())
            place_of_birth = st.text_input("Place of Birth")
            blood_type     = st.text_input("Blood Type")
        with col2:
            religion       = st.text_input("Religion")
            marital_status = st.selectbox("Marital Status",
                                          ["Single", "Married", "Divorced", "Widowed"])
            occupation     = st.text_input("Occupation")
            phone          = st.text_input("Phone Number")
            email          = st.text_input("Email")

        # ── Address ────────────────────────────
        st.markdown("### Current Address")
        col3, col4 = st.columns(2)
        with col3:
            governorate = st.text_input("Governorate")
            city        = st.text_input("City *")
            district    = st.text_input("District")
        with col4:
            street      = st.text_input("Street")
            building    = st.text_input("Building Number")
            postal      = st.text_input("Postal Code")

        # ── ID Card ────────────────────────────
        st.markdown("### National ID Card")
        col5, col6 = st.columns(2)
        with col5:
            issue_date  = st.date_input("Issue Date", value=date.today())
        with col6:
            expiry_date = st.date_input(
                "Expiry Date",
                value=date(date.today().year + 10,
                           date.today().month,
                           date.today().day)
            )
        card_status = st.selectbox("Card Status", ["Active", "Expired", "Suspended"])

        # ── Birth Record ───────────────────────
        st.markdown("### Birth Record")
        col7, col8 = st.columns(2)
        with col7:
            reg_date = st.date_input("Registration Date", value=date.today())
            hospital = st.text_input("Hospital Name")
        with col8:
            doctor    = st.text_input("Doctor Name")
            father_id = st.number_input("Father CitizenID (0 = none)", min_value=0, value=0, step=1)
            mother_id = st.number_input("Mother CitizenID (0 = none)", min_value=0, value=0, step=1)

        submitted = st.form_submit_button("Register Citizen")

        if submitted:
            if not national_id or not first_name or not last_name or not city:
                st.error("National ID, First Name, Last Name and City are required.")
            else:
                try:
                    # Insert citizen and get the new CitizenID back
                    row = fetch_one(
                        """
                        INSERT INTO Citizen
                            (NationalID, FirstName, LastName, Gender, DateOfBirth,
                             PlaceOfBirth, BloodType, Religion, MaritalStatus,
                             Occupation, PhoneNumber, Email)
                        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
                        RETURNING CitizenID
                        """,
                        (national_id, first_name, last_name, gender, dob,
                         place_of_birth, blood_type, religion, marital_status,
                         occupation, phone, email)
                    )
                    new_id = row["citizenid"]

                    # Insert address
                    execute(
                        """
                        INSERT INTO Address
                            (CitizenID, Governorate, City, District,
                             Street, BuildingNumber, PostalCode, IsCurrent)
                        VALUES (%s,%s,%s,%s,%s,%s,%s, TRUE)
                        """,
                        (new_id, governorate, city, district,
                         street, building, postal)
                    )

                    # Insert ID card
                    execute(
                        """
                        INSERT INTO NationalIDCard
                            (CitizenID, IssueDate, ExpiryDate, CardStatus)
                        VALUES (%s,%s,%s,%s)
                        """,
                        (new_id, issue_date, expiry_date, card_status)
                    )

                    # Insert birth record
                    execute(
                        """
                        INSERT INTO BirthRecord
                            (CitizenID, RegistrationDate, HospitalName,
                             DoctorName, FatherID, MotherID)
                        VALUES (%s,%s,%s,%s,%s,%s)
                        """,
                        (new_id, reg_date, hospital, doctor,
                         father_id if father_id != 0 else None,
                         mother_id if mother_id != 0 else None)
                    )

                    st.success(
                        f"✅ {first_name} {last_name} registered successfully "
                        f"with CitizenID {new_id}."
                    )

                except Exception as e:
                    st.error(f"Something went wrong: {e}")

# ──────────────────────────────────────────────
# 3. Search Citizen
# ──────────────────────────────────────────────
elif option == "Search Citizen":
    st.header("Search Citizen by National ID")

    search_nid = st.text_input("Enter National ID")

    if st.button("Search"):
        if not search_nid.strip():
            st.warning("Please enter a National ID.")
        else:
            citizen = fetch_one(
                "SELECT CitizenID FROM Citizen WHERE NationalID = %s",
                (search_nid.strip(),)
            )
            if citizen:
                details = get_full_details(citizen["citizenid"])
                full_name = f"{details.get('firstname','')} {details.get('lastname','')}"
                display_full_details(details, f"Search Result — {full_name}")
            else:
                st.error("No citizen found with that National ID.")
