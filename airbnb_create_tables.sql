-- ================================
-- SQL Script for Airbnb Database
-- Created on: [01/10/2024]
-- Description: This script contains the CREATE TABLE statements for the Airbnb database,
-- including listings, detailed listings, neighbourhoods, reviews, and detailed reviews.
-- ================================
CREATE TABLE IF NOT EXISTS calendar (
    listing_id integer,
    date date,
    available boolean,
    price numeric(10, 2),
    adjusted_price numeric(10, 2),
    minimum_nights integer,
    maximum_nights integer
);


CREATE TABLE IF NOT EXISTS listings (
    id integer NOT NULL,
    name character varying(255) COLLATE pg_catalog."default",
    host_id integer,
    host_name character varying(255) COLLATE pg_catalog."default",
    neighbourhood_group character varying(255) COLLATE pg_catalog."default",
    neighbourhood character varying(255) COLLATE pg_catalog."default",
    latitude numeric(10, 8),
    longitude numeric(11, 8),
    room_type character varying(50) COLLATE pg_catalog."default",
    price numeric(10, 2),
    minimum_nights integer,
    number_of_reviews integer,
    last_review date,
    reviews_per_month numeric(4, 2),
    calculated_host_listings_count integer,
    availability_365 integer,
    CONSTRAINT listings_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS listings_detailed (
    id integer NOT NULL,
    listing_url character varying(500) COLLATE pg_catalog."default",
    scrape_id bigint,
    last_scraped date,
    name character varying(255) COLLATE pg_catalog."default",
    description text COLLATE pg_catalog."default",
    neighborhood_overview text COLLATE pg_catalog."default",
    picture_url character varying(500) COLLATE pg_catalog."default",
    host_id integer,
    host_url character varying(500) COLLATE pg_catalog."default",
    host_name character varying(255) COLLATE pg_catalog."default",
    host_since date,
    host_location character varying(255) COLLATE pg_catalog."default",
    host_about text COLLATE pg_catalog."default",
    host_response_time character varying(255) COLLATE pg_catalog."default",
    host_response_rate character varying(10) COLLATE pg_catalog."default",
    host_acceptance_rate character varying(10) COLLATE pg_catalog."default",
    host_is_superhost boolean,
    host_thumbnail_url character varying(500) COLLATE pg_catalog."default",
    host_picture_url character varying(500) COLLATE pg_catalog."default",
    host_neighbourhood character varying(255) COLLATE pg_catalog."default",
    host_listings_count integer,
    host_total_listings_count integer,
    host_verifications character varying(500) COLLATE pg_catalog."default",
    host_has_profile_pic boolean,
    host_identity_verified boolean,
    neighbourhood character varying(255) COLLATE pg_catalog."default",
    neighbourhood_cleansed character varying(255) COLLATE pg_catalog."default",
    neighbourhood_group_cleansed character varying(255) COLLATE pg_catalog."default",
    latitude numeric(10, 8),
    longitude numeric(11, 8),
    property_type character varying(255) COLLATE pg_catalog."default",
    room_type character varying(50) COLLATE pg_catalog."default",
    accommodates integer,
    bathrooms numeric(3, 1),
    bathrooms_text character varying(255) COLLATE pg_catalog."default",
    bedrooms integer,
    beds integer,
    amenities text COLLATE pg_catalog."default",
    price numeric(10, 2),
    minimum_nights integer,
    maximum_nights integer,
    minimum_minimum_nights integer,
    maximum_minimum_nights integer,
    minimum_maximum_nights integer,
    maximum_maximum_nights integer,
    minimum_nights_avg_ntm numeric(10, 2),
    maximum_nights_avg_ntm numeric(10, 2),
    calendar_updated character varying(255) COLLATE pg_catalog."default",
    has_availability boolean,
    availability_30 integer,
    availability_60 integer,
    availability_90 integer,
    availability_365 integer,
    calendar_last_scraped date,
    number_of_reviews integer,
    number_of_reviews_ltm integer,
    number_of_reviews_l30d integer,
    first_review date,
    last_review date,
    review_scores_rating numeric(10, 2),
    review_scores_accuracy numeric(10, 2),
    review_scores_cleanliness numeric(10, 2),
    review_scores_checkin numeric(10, 2),
    review_scores_communication numeric(10, 2),
    review_scores_location numeric(10, 2),
    review_scores_value numeric(10, 2),
    license character varying(500) COLLATE pg_catalog."default",
    instant_bookable boolean,
    calculated_host_listings_count integer,
    calculated_host_listings_count_entire_homes integer,
    calculated_host_listings_count_private_rooms integer,
    calculated_host_listings_count_shared_rooms integer,
    reviews_per_month numeric(4, 2),
    CONSTRAINT listings_detailed_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS neighbourhood (
    neighbourhood_group character varying(255) COLLATE pg_catalog."default" NOT NULL,
    neighbourhood character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT neighbourhood_pkey PRIMARY KEY (neighbourhood_group, neighbourhood)
);
CREATE TABLE IF NOT EXISTS reviews (
    listing_id integer,
    date date
);
CREATE TABLE IF NOT EXISTS reviews_detailed (
    listing_id integer,
    id integer NOT NULL,
    date date,
    reviewer_id integer,
    reviewer_name character varying(255) COLLATE pg_catalog."default",
    comments text COLLATE pg_catalog."default",
    CONSTRAINT reviews_detailed_pkey PRIMARY KEY (id)
);
