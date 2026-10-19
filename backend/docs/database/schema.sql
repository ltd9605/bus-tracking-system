CREATE TABLE `AspNetUsers` (
  `Id` varchar(36) PRIMARY KEY NOT NULL,
  `UserName` varchar(256),
  `NormalizedUserName` varchar(256),
  `Email` varchar(256),
  `NormalizedEmail` varchar(256),
  `EmailConfirmed` boolean NOT NULL DEFAULT false,
  `DisplayName` varchar(150) NOT NULL,
  `AvatarUrl` varchar(1024),
  `Status` varchar(24) NOT NULL DEFAULT 'Active' COMMENT 'Active | Disabled',
  `PasswordHash` text COMMENT 'Nullable for Google-only users; local password login is outside MVP.',
  `SecurityStamp` varchar(256),
  `ConcurrencyStamp` varchar(256),
  `PhoneNumber` varchar(32),
  `PhoneNumberConfirmed` boolean NOT NULL DEFAULT false,
  `TwoFactorEnabled` boolean NOT NULL DEFAULT false,
  `LockoutEnd` datetime(6),
  `LockoutEnabled` boolean NOT NULL DEFAULT true,
  `AccessFailedCount` int NOT NULL DEFAULT 0,
  `CreatedAtUtc` datetime(6) NOT NULL,
  `UpdatedAtUtc` datetime(6),
  CONSTRAINT `CK_Users_Status` CHECK (Status IN ('Active', 'Disabled')),
  CONSTRAINT `CK_Users_FailedCount` CHECK (AccessFailedCount >= 0)
);

CREATE TABLE `AspNetRoles` (
  `Id` varchar(36) PRIMARY KEY NOT NULL,
  `Name` varchar(256) NOT NULL COMMENT 'Passenger, Driver, Admin, Dispatcher, SuperAdmin',
  `NormalizedName` varchar(256) NOT NULL,
  `ConcurrencyStamp` varchar(256),
  `Description` varchar(255),
  `IsSystemRole` boolean NOT NULL DEFAULT false
);

CREATE TABLE `AspNetUserRoles` (
  `UserId` varchar(36) NOT NULL,
  `RoleId` varchar(36) NOT NULL,
  `GrantedAtUtc` datetime(6) NOT NULL,
  `GrantedByUserId` varchar(36),
  PRIMARY KEY (`UserId`, `RoleId`)
);

CREATE TABLE `AspNetUserLogins` (
  `LoginProvider` varchar(128) NOT NULL COMMENT 'Google',
  `ProviderKey` varchar(255) NOT NULL COMMENT 'Stable issuer plus subject key; populate consistently in backend.',
  `ProviderDisplayName` varchar(256),
  `UserId` varchar(36) NOT NULL,
  `Issuer` varchar(255) NOT NULL,
  `ProviderSubject` varchar(255) NOT NULL COMMENT 'OIDC sub, not the user email',
  `LinkedAtUtc` datetime(6) NOT NULL,
  `LastLoginAtUtc` datetime(6),
  PRIMARY KEY (`LoginProvider`, `ProviderKey`)
);

CREATE TABLE `Permissions` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `Code` varchar(128) UNIQUE NOT NULL COMMENT 'Example: trip.execute.assigned',
  `Description` varchar(255),
  `Module` varchar(64) NOT NULL
);

CREATE TABLE `RolePermissions` (
  `RoleId` varchar(36) NOT NULL,
  `PermissionId` bigint NOT NULL,
  `GrantedAtUtc` datetime(6) NOT NULL,
  PRIMARY KEY (`RoleId`, `PermissionId`)
);

CREATE TABLE `Sessions` (
  `Id` varchar(36) PRIMARY KEY NOT NULL,
  `UserId` varchar(36) NOT NULL,
  `SessionKeyHash` char(64) UNIQUE NOT NULL COMMENT 'Hash of random opaque session key; never store a raw bearer secret.',
  `CreatedAtUtc` datetime(6) NOT NULL,
  `ExpiresAtUtc` datetime(6) NOT NULL,
  `LastSeenAtUtc` datetime(6),
  `RevokedAtUtc` datetime(6),
  `DeviceInfo` varchar(255),
  `IpAddress` varchar(45),
  CONSTRAINT `CK_Sessions_Expiry` CHECK (ExpiresAtUtc > CreatedAtUtc)
);

CREATE TABLE `PassengerProfiles` (
  `UserId` varchar(36) PRIMARY KEY NOT NULL,
  `PreferredLanguage` varchar(10) NOT NULL DEFAULT 'vi',
  `NotificationsEnabled` boolean NOT NULL DEFAULT true,
  `SettingsJson` json,
  `UpdatedAtUtc` datetime(6)
);

CREATE TABLE `DriverProfiles` (
  `UserId` varchar(36) PRIMARY KEY NOT NULL,
  `EmployeeCode` varchar(30) UNIQUE NOT NULL,
  `EligibilityStatus` varchar(24) NOT NULL DEFAULT 'Pending' COMMENT 'Pending | Active | Suspended | Disabled',
  `LicenseReference` varchar(100),
  `ApprovedByUserId` varchar(36),
  `ApprovedAtUtc` datetime(6),
  `CreatedAtUtc` datetime(6) NOT NULL,
  CONSTRAINT `CK_Drivers_Eligibility` CHECK (EligibilityStatus IN ('Pending', 'Active', 'Suspended', 'Disabled'))
);

CREATE TABLE `AspNetUserClaims` (
  `Id` int PRIMARY KEY AUTO_INCREMENT,
  `UserId` varchar(36) NOT NULL,
  `ClaimType` varchar(256),
  `ClaimValue` text
);

CREATE TABLE `AspNetRoleClaims` (
  `Id` int PRIMARY KEY AUTO_INCREMENT,
  `RoleId` varchar(36) NOT NULL,
  `ClaimType` varchar(256),
  `ClaimValue` text
);

CREATE TABLE `AspNetUserTokens` (
  `UserId` varchar(36) NOT NULL,
  `LoginProvider` varchar(128) NOT NULL,
  `Name` varchar(128) NOT NULL,
  `Value` text COMMENT 'ASP.NET Identity infrastructure; do not persist Google tokens for sign-in only.',
  PRIMARY KEY (`UserId`, `LoginProvider`, `Name`)
);

CREATE TABLE `Routes` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `Code` varchar(30) UNIQUE NOT NULL,
  `Name` varchar(200) NOT NULL,
  `Description` text,
  `Color` char(7),
  `Status` varchar(24) NOT NULL DEFAULT 'Draft' COMMENT 'Draft | Published | Archived',
  `PublishedAtUtc` datetime(6),
  `CreatedAtUtc` datetime(6) NOT NULL,
  `UpdatedAtUtc` datetime(6),
  CONSTRAINT `CK_Routes_Status` CHECK (Status IN ('Draft', 'Published', 'Archived'))
);

CREATE TABLE `Stops` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `Code` varchar(30) UNIQUE NOT NULL,
  `Name` varchar(200) NOT NULL,
  `Address` varchar(300),
  `Latitude` decimal(10,7) NOT NULL,
  `Longitude` decimal(10,7) NOT NULL,
  `IsAccessible` boolean NOT NULL DEFAULT false,
  `Status` varchar(24) NOT NULL DEFAULT 'Active',
  `CreatedAtUtc` datetime(6) NOT NULL,
  `UpdatedAtUtc` datetime(6),
  CONSTRAINT `CK_Stops_Latitude` CHECK (Latitude BETWEEN -90 AND 90),
  CONSTRAINT `CK_Stops_Longitude` CHECK (Longitude BETWEEN -180 AND 180),
  CONSTRAINT `CK_Stops_Status` CHECK (Status IN ('Active', 'Inactive'))
);

CREATE TABLE `RoutePatterns` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `RouteId` bigint NOT NULL,
  `PatternCode` varchar(30) NOT NULL COMMENT 'Distinguishes variants having same direction',
  `Direction` varchar(24) NOT NULL COMMENT 'Outbound | Inbound | Loop',
  `Name` varchar(150) NOT NULL,
  `Version` int NOT NULL DEFAULT 1,
  `GeometryJson` json COMMENT 'GeoJSON route geometry; validate geometry in application.',
  `Status` varchar(24) NOT NULL DEFAULT 'Draft',
  `PublishedAtUtc` datetime(6),
  `CreatedAtUtc` datetime(6) NOT NULL,
  CONSTRAINT `CK_Patterns_Version` CHECK (Version > 0),
  CONSTRAINT `CK_Patterns_Direction` CHECK (Direction IN ('Outbound', 'Inbound', 'Loop')),
  CONSTRAINT `CK_Patterns_Status` CHECK (Status IN ('Draft', 'Published', 'Archived'))
);

CREATE TABLE `RoutePatternStops` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `RoutePatternId` bigint NOT NULL,
  `StopId` bigint NOT NULL,
  `Sequence` int NOT NULL COMMENT 'May visit the same Stop twice at different Sequence values.',
  `DistanceMeters` int NOT NULL DEFAULT 0,
  CONSTRAINT `CK_PatternStops_Sequence` CHECK (Sequence >= 1),
  CONSTRAINT `CK_PatternStops_Distance` CHECK (DistanceMeters >= 0)
);

CREATE TABLE `ServiceCalendars` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `Name` varchar(120) NOT NULL,
  `StartDate` date NOT NULL,
  `EndDate` date NOT NULL,
  `Monday` boolean NOT NULL DEFAULT false,
  `Tuesday` boolean NOT NULL DEFAULT false,
  `Wednesday` boolean NOT NULL DEFAULT false,
  `Thursday` boolean NOT NULL DEFAULT false,
  `Friday` boolean NOT NULL DEFAULT false,
  `Saturday` boolean NOT NULL DEFAULT false,
  `Sunday` boolean NOT NULL DEFAULT false,
  `ExceptionsJson` json COMMENT 'Specification mentions calendar exceptions but no separate entity. JSON array of {serviceDate, exceptionType}; validate app-side.',
  `Status` varchar(24) NOT NULL DEFAULT 'Draft',
  `CreatedAtUtc` datetime(6) NOT NULL,
  CONSTRAINT `CK_Calendars_DateRange` CHECK (EndDate >= StartDate),
  CONSTRAINT `CK_Calendars_Status` CHECK (Status IN ('Draft', 'Published', 'Archived'))
);

CREATE TABLE `TripPlans` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `RoutePatternId` bigint NOT NULL,
  `ServiceCalendarId` bigint NOT NULL,
  `PublicHeadsign` varchar(150) NOT NULL,
  `PlannedStartSeconds` int NOT NULL COMMENT 'Seconds after service-day midnight; >86400 supports next-day service.',
  `Status` varchar(24) NOT NULL DEFAULT 'Draft',
  `CreatedAtUtc` datetime(6) NOT NULL,
  `PublishedAtUtc` datetime(6),
  CONSTRAINT `CK_TripPlans_StartSeconds` CHECK (PlannedStartSeconds >= 0 AND PlannedStartSeconds < 172800),
  CONSTRAINT `CK_TripPlans_Status` CHECK (Status IN ('Draft', 'Published', 'Archived'))
);

CREATE TABLE `PlannedStopTimes` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `TripPlanId` bigint NOT NULL,
  `StopId` bigint NOT NULL,
  `Sequence` int NOT NULL COMMENT 'Must match the route pattern sequence; check in application.',
  `ArrivalSeconds` int NOT NULL,
  `DepartureSeconds` int NOT NULL,
  CONSTRAINT `CK_PlannedStops_Sequence` CHECK (Sequence >= 1),
  CONSTRAINT `CK_PlannedStops_Arrival` CHECK (ArrivalSeconds >= 0 AND ArrivalSeconds < 172800),
  CONSTRAINT `CK_PlannedStops_Departure` CHECK (DepartureSeconds >= ArrivalSeconds AND DepartureSeconds < 172800)
);

CREATE TABLE `Vehicles` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `FleetNumber` varchar(30) UNIQUE NOT NULL,
  `PublicLabel` varchar(100) NOT NULL,
  `PlateNumber` varchar(20) UNIQUE,
  `Capacity` int NOT NULL,
  `Status` varchar(24) NOT NULL DEFAULT 'Available' COMMENT 'Available | InService | Maintenance | Disabled',
  `CreatedAtUtc` datetime(6) NOT NULL,
  `UpdatedAtUtc` datetime(6),
  CONSTRAINT `CK_Vehicles_Capacity` CHECK (Capacity > 0),
  CONSTRAINT `CK_Vehicles_Status` CHECK (Status IN ('Available', 'InService', 'Maintenance', 'Disabled'))
);

CREATE TABLE `TripInstances` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `TripPlanId` bigint NOT NULL,
  `ServiceDate` date NOT NULL COMMENT 'Date in configured service time zone, not necessarily UTC date',
  `OccurrenceKey` int NOT NULL DEFAULT 0 COMMENT 'Disambiguates extra runs for one trip plan and date',
  `RoutePatternId` bigint NOT NULL COMMENT 'Route pattern snapshot reference; published version stays immutable.',
  `PublicHeadsignSnapshot` varchar(150) NOT NULL,
  `PlannedStartAtUtc` datetime(6) NOT NULL,
  `StopTimesSnapshotJson` json NOT NULL COMMENT 'Immutable planned stop sequence/times snapshot for historical consistency; no TripInstanceStops table in source entity list.',
  `Status` varchar(24) NOT NULL DEFAULT 'Planned',
  `Version` bigint NOT NULL DEFAULT 1 COMMENT 'Application-managed optimistic concurrency token',
  `StartedAtUtc` datetime(6),
  `EndedAtUtc` datetime(6),
  `CreatedAtUtc` datetime(6) NOT NULL,
  CONSTRAINT `CK_TripInstances_Occurrence` CHECK (OccurrenceKey >= 0),
  CONSTRAINT `CK_TripInstances_Version` CHECK (Version > 0),
  CONSTRAINT `CK_TripInstances_Status` CHECK (Status IN ('Planned', 'Ready', 'InProgress', 'Paused', 'Completed', 'Cancelled', 'Aborted'))
);

CREATE TABLE `TripAssignments` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `TripInstanceId` bigint NOT NULL,
  `DriverUserId` varchar(36) NOT NULL,
  `VehicleId` bigint NOT NULL,
  `StartsAtUtc` datetime(6) NOT NULL,
  `EndsAtUtc` datetime(6) NOT NULL,
  `Status` varchar(24) NOT NULL DEFAULT 'Assigned' COMMENT 'Assigned | Accepted | Released | Cancelled',
  `AssignedByUserId` varchar(36) NOT NULL,
  `AssignedAtUtc` datetime(6) NOT NULL,
  `ReleasedAtUtc` datetime(6),
  CONSTRAINT `CK_Assignments_TimeWindow` CHECK (EndsAtUtc > StartsAtUtc),
  CONSTRAINT `CK_Assignments_Status` CHECK (Status IN ('Assigned', 'Accepted', 'Released', 'Cancelled'))
);

CREATE TABLE `TripEvents` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `TripInstanceId` bigint NOT NULL,
  `EventType` varchar(40) NOT NULL COMMENT 'Ready | Start | Pause | Resume | Complete | Cancel | Abort | StopArrive | StopSkip | IncidentReported',
  `OldStatus` varchar(24),
  `NewStatus` varchar(24),
  `VersionAfter` bigint COMMENT 'Trip version after accepted state transition; NULL for stop/incident log events',
  `EventSequence` bigint NOT NULL COMMENT 'Unique timeline sequence scoped to trip; increment transactionally',
  `StopId` bigint COMMENT 'Optional stop for arrival/skip events',
  `StopSequence` int COMMENT 'Optional sequence when the same stop occurs more than once',
  `EventDetailsJson` json COMMENT 'Optional incident or operational detail; not a substitute for a separate Incident entity if independently managed incidents are required',
  `ActorUserId` varchar(36),
  `Reason` varchar(500),
  `IdempotencyKey` varchar(100),
  `OccurredAtUtc` datetime(6) NOT NULL,
  CONSTRAINT `CK_TripEvents_Version` CHECK (VersionAfter IS NULL OR VersionAfter > 0),
  CONSTRAINT `CK_TripEvents_Sequence` CHECK (EventSequence > 0)
);

CREATE TABLE `VehicleLatestLocations` (
  `VehicleId` bigint PRIMARY KEY NOT NULL COMMENT 'Exactly one latest location per vehicle',
  `TripInstanceId` bigint,
  `Latitude` decimal(10,7) NOT NULL,
  `Longitude` decimal(10,7) NOT NULL,
  `AccuracyMeters` decimal(8,2),
  `HeadingDegrees` decimal(5,2),
  `SpeedKmh` decimal(7,2),
  `Sequence` bigint NOT NULL,
  `CapturedAtUtc` datetime(6) NOT NULL,
  `ReceivedAtUtc` datetime(6) NOT NULL,
  `Version` bigint NOT NULL DEFAULT 1,
  CONSTRAINT `CK_LatestLocations_Lat` CHECK (Latitude BETWEEN -90 AND 90),
  CONSTRAINT `CK_LatestLocations_Lon` CHECK (Longitude BETWEEN -180 AND 180),
  CONSTRAINT `CK_LatestLocations_Accuracy` CHECK (AccuracyMeters IS NULL OR AccuracyMeters >= 0),
  CONSTRAINT `CK_LatestLocations_Heading` CHECK (HeadingDegrees IS NULL OR (HeadingDegrees >= 0 AND HeadingDegrees < 360)),
  CONSTRAINT `CK_LatestLocations_Speed` CHECK (SpeedKmh IS NULL OR SpeedKmh >= 0),
  CONSTRAINT `CK_LatestLocations_Version` CHECK (Sequence >= 0 AND Version > 0)
);

CREATE TABLE `VehicleLocationSamples` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `VehicleId` bigint NOT NULL,
  `TripInstanceId` bigint NOT NULL,
  `Latitude` decimal(10,7) NOT NULL,
  `Longitude` decimal(10,7) NOT NULL,
  `AccuracyMeters` decimal(8,2),
  `HeadingDegrees` decimal(5,2),
  `SpeedKmh` decimal(7,2),
  `Sequence` bigint NOT NULL,
  `CapturedAtUtc` datetime(6) NOT NULL,
  `ReceivedAtUtc` datetime(6) NOT NULL,
  `IsUsableForEta` boolean NOT NULL DEFAULT true,
  CONSTRAINT `CK_LocationSamples_Lat` CHECK (Latitude BETWEEN -90 AND 90),
  CONSTRAINT `CK_LocationSamples_Lon` CHECK (Longitude BETWEEN -180 AND 180),
  CONSTRAINT `CK_LocationSamples_Accuracy` CHECK (AccuracyMeters IS NULL OR AccuracyMeters >= 0),
  CONSTRAINT `CK_LocationSamples_Sequence` CHECK (Sequence >= 0)
);

CREATE TABLE `ArrivalPredictions` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `TripInstanceId` bigint NOT NULL,
  `StopId` bigint NOT NULL,
  `PredictedArrivalAtUtc` datetime(6),
  `CalculatedAtUtc` datetime(6) NOT NULL,
  `Source` varchar(40) NOT NULL COMMENT 'GpsEstimate | RoutingProvider | Schedule',
  `Confidence` decimal(5,4),
  `Status` varchar(24) NOT NULL COMMENT 'Live | Stale | ScheduledOnly | Unavailable',
  `Version` bigint NOT NULL DEFAULT 1,
  CONSTRAINT `CK_Predictions_Confidence` CHECK (Confidence IS NULL OR (Confidence >= 0 AND Confidence <= 1)),
  CONSTRAINT `CK_Predictions_Status` CHECK (Status IN ('Live', 'Stale', 'ScheduledOnly', 'Unavailable')),
  CONSTRAINT `CK_Predictions_Version` CHECK (Version > 0)
);

CREATE TABLE `Favorites` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `UserId` varchar(36) NOT NULL,
  `RouteId` bigint,
  `StopId` bigint,
  `CreatedAtUtc` datetime(6) NOT NULL,
  CONSTRAINT `CK_Favorites_OneTarget` CHECK ((RouteId IS NOT NULL AND StopId IS NULL) OR (RouteId IS NULL AND StopId IS NOT NULL))
);

CREATE TABLE `Subscriptions` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `UserId` varchar(36) NOT NULL,
  `RouteId` bigint,
  `StopId` bigint,
  `SubscriptionType` varchar(32) NOT NULL COMMENT 'Delay | ServiceChange | ApproachingStop',
  `Channel` varchar(20) NOT NULL DEFAULT 'InApp',
  `IsEnabled` boolean NOT NULL DEFAULT true,
  `CreatedAtUtc` datetime(6) NOT NULL,
  `UpdatedAtUtc` datetime(6),
  CONSTRAINT `CK_Subscriptions_OneTarget` CHECK ((RouteId IS NOT NULL AND StopId IS NULL) OR (RouteId IS NULL AND StopId IS NOT NULL)),
  CONSTRAINT `CK_Subscriptions_Type` CHECK (SubscriptionType IN ('Delay', 'ServiceChange', 'ApproachingStop')),
  CONSTRAINT `CK_Subscriptions_Channel` CHECK (Channel IN ('InApp', 'WebPush', 'Email'))
);

CREATE TABLE `ServiceAlerts` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `Title` varchar(200) NOT NULL,
  `Body` text NOT NULL,
  `Severity` varchar(24) NOT NULL,
  `Status` varchar(24) NOT NULL DEFAULT 'Draft',
  `StartsAtUtc` datetime(6) NOT NULL,
  `EndsAtUtc` datetime(6) NOT NULL,
  `PublishedAtUtc` datetime(6),
  `CreatedByUserId` varchar(36) NOT NULL,
  `RouteId` bigint COMMENT 'Affected route. Strict 28-entity baseline supports one target per alert record.',
  `StopId` bigint COMMENT 'Affected stop',
  `TripInstanceId` bigint COMMENT 'Affected trip',
  `CreatedAtUtc` datetime(6) NOT NULL,
  `UpdatedAtUtc` datetime(6),
  CONSTRAINT `CK_Alerts_TimeWindow` CHECK (EndsAtUtc > StartsAtUtc),
  CONSTRAINT `CK_Alerts_ExactlyOneTarget` CHECK (((RouteId IS NOT NULL) + (StopId IS NOT NULL) + (TripInstanceId IS NOT NULL)) = 1),
  CONSTRAINT `CK_Alerts_Severity` CHECK (Severity IN ('Info', 'Warning', 'Critical')),
  CONSTRAINT `CK_Alerts_Status` CHECK (Status IN ('Draft', 'Published', 'Ended', 'Cancelled'))
);

CREATE TABLE `AuditLogs` (
  `Id` bigint PRIMARY KEY AUTO_INCREMENT,
  `ActorUserId` varchar(36) COMMENT 'Nullable for system worker; redact secrets and PII',
  `Action` varchar(120) NOT NULL,
  `EntityType` varchar(80) NOT NULL,
  `EntityId` varchar(64) NOT NULL,
  `BeforeJson` json,
  `AfterJson` json,
  `IpAddress` varchar(45),
  `CorrelationId` varchar(100) NOT NULL,
  `OccurredAtUtc` datetime(6) NOT NULL
);

CREATE TABLE `OutboxMessages` (
  `Id` varchar(36) PRIMARY KEY NOT NULL COMMENT 'EventId',
  `AggregateType` varchar(80) NOT NULL,
  `AggregateId` varchar(64) NOT NULL,
  `EventType` varchar(120) NOT NULL,
  `EventVersion` bigint NOT NULL,
  `PayloadJson` json NOT NULL,
  `CreatedAtUtc` datetime(6) NOT NULL,
  `ProcessedAtUtc` datetime(6),
  `Attempts` int NOT NULL DEFAULT 0,
  `LastError` text,
  CONSTRAINT `CK_Outbox_Attempts` CHECK (Attempts >= 0),
  CONSTRAINT `CK_Outbox_Version` CHECK (EventVersion > 0)
);

CREATE UNIQUE INDEX `UX_Users_NormalizedUserName` ON `AspNetUsers` (`NormalizedUserName`);

CREATE INDEX `IX_Users_NormalizedEmail` ON `AspNetUsers` (`NormalizedEmail`);

CREATE INDEX `IX_Users_Status` ON `AspNetUsers` (`Status`);

CREATE UNIQUE INDEX `UX_Roles_NormalizedName` ON `AspNetRoles` (`NormalizedName`);

CREATE INDEX `IX_UserRoles_Role` ON `AspNetUserRoles` (`RoleId`);

CREATE UNIQUE INDEX `UX_Logins_ExternalIdentity` ON `AspNetUserLogins` (`LoginProvider`, `Issuer`, `ProviderSubject`);

CREATE INDEX `IX_Logins_User` ON `AspNetUserLogins` (`UserId`);

CREATE INDEX `IX_RolePermissions_Permission` ON `RolePermissions` (`PermissionId`);

CREATE INDEX `IX_Sessions_User_Expiry` ON `Sessions` (`UserId`, `ExpiresAtUtc`);

CREATE INDEX `IX_UserClaims_User` ON `AspNetUserClaims` (`UserId`);

CREATE INDEX `IX_RoleClaims_Role` ON `AspNetRoleClaims` (`RoleId`);

CREATE INDEX `IX_Routes_Status_Name` ON `Routes` (`Status`, `Name`);

CREATE INDEX `IX_Stops_Coordinates` ON `Stops` (`Latitude`, `Longitude`);

CREATE INDEX `IX_Stops_Status_Name` ON `Stops` (`Status`, `Name`);

CREATE UNIQUE INDEX `UX_Patterns_Route_Code_Version` ON `RoutePatterns` (`RouteId`, `PatternCode`, `Version`);

CREATE INDEX `IX_Patterns_Route_Status` ON `RoutePatterns` (`RouteId`, `Status`);

CREATE UNIQUE INDEX `UX_PatternStops_Pattern_Sequence` ON `RoutePatternStops` (`RoutePatternId`, `Sequence`);

CREATE INDEX `IX_PatternStops_Stop` ON `RoutePatternStops` (`StopId`);

CREATE INDEX `IX_TripPlans_Schedule` ON `TripPlans` (`RoutePatternId`, `ServiceCalendarId`, `PlannedStartSeconds`);

CREATE UNIQUE INDEX `UX_PlannedStopTimes_Trip_Sequence` ON `PlannedStopTimes` (`TripPlanId`, `Sequence`);

CREATE INDEX `IX_PlannedStopTimes_Stop` ON `PlannedStopTimes` (`StopId`);

CREATE INDEX `IX_Vehicles_Status` ON `Vehicles` (`Status`);

CREATE UNIQUE INDEX `UX_TripInstances_Plan_Date_Occurrence` ON `TripInstances` (`TripPlanId`, `ServiceDate`, `OccurrenceKey`);

CREATE INDEX `IX_TripInstances_Date_Status` ON `TripInstances` (`ServiceDate`, `Status`);

CREATE INDEX `IX_TripInstances_Pattern_Date` ON `TripInstances` (`RoutePatternId`, `ServiceDate`);

CREATE INDEX `IX_Assignments_Trip_Status` ON `TripAssignments` (`TripInstanceId`, `Status`);

CREATE INDEX `IX_Assignments_Driver_Window` ON `TripAssignments` (`DriverUserId`, `StartsAtUtc`, `EndsAtUtc`);

CREATE INDEX `IX_Assignments_Vehicle_Window` ON `TripAssignments` (`VehicleId`, `StartsAtUtc`, `EndsAtUtc`);

CREATE UNIQUE INDEX `UX_TripEvents_Trip_Version` ON `TripEvents` (`TripInstanceId`, `VersionAfter`);

CREATE UNIQUE INDEX `UX_TripEvents_Trip_Sequence` ON `TripEvents` (`TripInstanceId`, `EventSequence`);

CREATE UNIQUE INDEX `UX_TripEvents_Trip_Idempotency` ON `TripEvents` (`TripInstanceId`, `IdempotencyKey`);

CREATE INDEX `IX_TripEvents_Trip_Time` ON `TripEvents` (`TripInstanceId`, `OccurredAtUtc`);

CREATE INDEX `IX_TripEvents_Stop_Time` ON `TripEvents` (`StopId`, `OccurredAtUtc`);

CREATE INDEX `IX_LatestLocations_Trip_Received` ON `VehicleLatestLocations` (`TripInstanceId`, `ReceivedAtUtc`);

CREATE INDEX `IX_LatestLocations_Received` ON `VehicleLatestLocations` (`ReceivedAtUtc`);

CREATE UNIQUE INDEX `UX_LocationSamples_Trip_Sequence` ON `VehicleLocationSamples` (`TripInstanceId`, `Sequence`);

CREATE INDEX `IX_LocationSamples_Trip_Captured` ON `VehicleLocationSamples` (`TripInstanceId`, `CapturedAtUtc`);

CREATE INDEX `IX_LocationSamples_Vehicle_Received` ON `VehicleLocationSamples` (`VehicleId`, `ReceivedAtUtc`);

CREATE UNIQUE INDEX `UX_Predictions_Trip_Stop` ON `ArrivalPredictions` (`TripInstanceId`, `StopId`);

CREATE INDEX `IX_Predictions_Stop_Arrival` ON `ArrivalPredictions` (`StopId`, `PredictedArrivalAtUtc`);

CREATE INDEX `IX_Predictions_Status_Time` ON `ArrivalPredictions` (`Status`, `CalculatedAtUtc`);

CREATE UNIQUE INDEX `UX_Favorites_User_Route` ON `Favorites` (`UserId`, `RouteId`);

CREATE UNIQUE INDEX `UX_Favorites_User_Stop` ON `Favorites` (`UserId`, `StopId`);

CREATE UNIQUE INDEX `UX_Subscriptions_User_Route_Type` ON `Subscriptions` (`UserId`, `RouteId`, `SubscriptionType`, `Channel`);

CREATE UNIQUE INDEX `UX_Subscriptions_User_Stop_Type` ON `Subscriptions` (`UserId`, `StopId`, `SubscriptionType`, `Channel`);

CREATE INDEX `IX_Alerts_ActiveWindow` ON `ServiceAlerts` (`Status`, `StartsAtUtc`, `EndsAtUtc`);

CREATE INDEX `IX_Alerts_Route_Start` ON `ServiceAlerts` (`RouteId`, `StartsAtUtc`);

CREATE INDEX `IX_Alerts_Stop_Start` ON `ServiceAlerts` (`StopId`, `StartsAtUtc`);

CREATE INDEX `IX_Alerts_Trip_Start` ON `ServiceAlerts` (`TripInstanceId`, `StartsAtUtc`);

CREATE INDEX `IX_Audit_Actor_Time` ON `AuditLogs` (`ActorUserId`, `OccurredAtUtc`);

CREATE INDEX `IX_Audit_Entity_Time` ON `AuditLogs` (`EntityType`, `EntityId`, `OccurredAtUtc`);

CREATE INDEX `IX_Audit_Correlation` ON `AuditLogs` (`CorrelationId`);

CREATE INDEX `IX_Audit_Occurred` ON `AuditLogs` (`OccurredAtUtc`);

CREATE INDEX `IX_Outbox_Pending` ON `OutboxMessages` (`ProcessedAtUtc`, `CreatedAtUtc`);

CREATE INDEX `IX_Outbox_Aggregate_Version` ON `OutboxMessages` (`AggregateType`, `AggregateId`, `EventVersion`);

ALTER TABLE `AspNetUserRoles` ADD FOREIGN KEY (`UserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE CASCADE;

ALTER TABLE `AspNetUserRoles` ADD FOREIGN KEY (`RoleId`) REFERENCES `AspNetRoles` (`Id`) ON DELETE CASCADE;

ALTER TABLE `AspNetUserRoles` ADD FOREIGN KEY (`GrantedByUserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE SET NULL;

ALTER TABLE `AspNetUserClaims` ADD FOREIGN KEY (`UserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE CASCADE;

ALTER TABLE `AspNetRoleClaims` ADD FOREIGN KEY (`RoleId`) REFERENCES `AspNetRoles` (`Id`) ON DELETE CASCADE;

ALTER TABLE `AspNetUserLogins` ADD FOREIGN KEY (`UserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE CASCADE;

ALTER TABLE `AspNetUserTokens` ADD FOREIGN KEY (`UserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE CASCADE;

ALTER TABLE `RolePermissions` ADD FOREIGN KEY (`RoleId`) REFERENCES `AspNetRoles` (`Id`) ON DELETE CASCADE;

ALTER TABLE `RolePermissions` ADD FOREIGN KEY (`PermissionId`) REFERENCES `Permissions` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `Sessions` ADD FOREIGN KEY (`UserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE CASCADE;

ALTER TABLE `PassengerProfiles` ADD FOREIGN KEY (`UserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE CASCADE;

ALTER TABLE `DriverProfiles` ADD FOREIGN KEY (`UserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `DriverProfiles` ADD FOREIGN KEY (`ApprovedByUserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE SET NULL;

ALTER TABLE `RoutePatterns` ADD FOREIGN KEY (`RouteId`) REFERENCES `Routes` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `RoutePatternStops` ADD FOREIGN KEY (`RoutePatternId`) REFERENCES `RoutePatterns` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `RoutePatternStops` ADD FOREIGN KEY (`StopId`) REFERENCES `Stops` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `TripPlans` ADD FOREIGN KEY (`RoutePatternId`) REFERENCES `RoutePatterns` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `TripPlans` ADD FOREIGN KEY (`ServiceCalendarId`) REFERENCES `ServiceCalendars` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `PlannedStopTimes` ADD FOREIGN KEY (`TripPlanId`) REFERENCES `TripPlans` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `PlannedStopTimes` ADD FOREIGN KEY (`StopId`) REFERENCES `Stops` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `TripInstances` ADD FOREIGN KEY (`TripPlanId`) REFERENCES `TripPlans` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `TripInstances` ADD FOREIGN KEY (`RoutePatternId`) REFERENCES `RoutePatterns` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `TripAssignments` ADD FOREIGN KEY (`TripInstanceId`) REFERENCES `TripInstances` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `TripAssignments` ADD FOREIGN KEY (`DriverUserId`) REFERENCES `DriverProfiles` (`UserId`) ON DELETE RESTRICT;

ALTER TABLE `TripAssignments` ADD FOREIGN KEY (`VehicleId`) REFERENCES `Vehicles` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `TripAssignments` ADD FOREIGN KEY (`AssignedByUserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `TripEvents` ADD FOREIGN KEY (`TripInstanceId`) REFERENCES `TripInstances` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `TripEvents` ADD FOREIGN KEY (`ActorUserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE SET NULL;

ALTER TABLE `VehicleLatestLocations` ADD FOREIGN KEY (`VehicleId`) REFERENCES `Vehicles` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `VehicleLatestLocations` ADD FOREIGN KEY (`TripInstanceId`) REFERENCES `TripInstances` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `VehicleLocationSamples` ADD FOREIGN KEY (`VehicleId`) REFERENCES `Vehicles` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `VehicleLocationSamples` ADD FOREIGN KEY (`TripInstanceId`) REFERENCES `TripInstances` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `Favorites` ADD FOREIGN KEY (`UserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE CASCADE;

ALTER TABLE `Favorites` ADD FOREIGN KEY (`RouteId`) REFERENCES `Routes` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `Favorites` ADD FOREIGN KEY (`StopId`) REFERENCES `Stops` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `Subscriptions` ADD FOREIGN KEY (`UserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE CASCADE;

ALTER TABLE `Subscriptions` ADD FOREIGN KEY (`RouteId`) REFERENCES `Routes` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `Subscriptions` ADD FOREIGN KEY (`StopId`) REFERENCES `Stops` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `ServiceAlerts` ADD FOREIGN KEY (`CreatedByUserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `AuditLogs` ADD FOREIGN KEY (`ActorUserId`) REFERENCES `AspNetUsers` (`Id`) ON DELETE SET NULL;

ALTER TABLE `TripEvents` ADD FOREIGN KEY (`StopId`) REFERENCES `Stops` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `ArrivalPredictions` ADD FOREIGN KEY (`TripInstanceId`) REFERENCES `TripInstances` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `ArrivalPredictions` ADD FOREIGN KEY (`StopId`) REFERENCES `Stops` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `ServiceAlerts` ADD FOREIGN KEY (`RouteId`) REFERENCES `Routes` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `ServiceAlerts` ADD FOREIGN KEY (`StopId`) REFERENCES `Stops` (`Id`) ON DELETE RESTRICT;

ALTER TABLE `ServiceAlerts` ADD FOREIGN KEY (`TripInstanceId`) REFERENCES `TripInstances` (`Id`) ON DELETE RESTRICT;
