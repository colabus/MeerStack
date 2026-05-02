USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Trend_Disks_Insert]

	@Payload nvarchar(MAX)

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @DeviceID varchar(50),
            @VolumeName varchar(50),
            @SizeGB float,
            @UsedGB float,
            @FreeGB float,
            @UsedPercent float,
            @Description varchar(50),
            @FileSystem varchar(50),
            @VolumeSerialNumber varchar(50)

    SELECT
        @Hostname  = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp = JSON_VALUE(@Payload, '$.Timestamp')

    SET NOCOUNT OFF

    DECLARE curDisks CURSOR FOR

    SELECT
        JSON_VALUE(Disk.value, '$.DeviceID'),
        JSON_VALUE(Disk.value, '$.VolumeName'),
        JSON_VALUE(Disk.value, '$.SizeGB'),
        JSON_VALUE(Disk.value, '$.UsedGB'),
        JSON_VALUE(Disk.value, '$.FreeGB'),
        JSON_VALUE(Disk.value, '$.UsedPercent'),
        JSON_VALUE(Disk.value, '$.Description'),
        JSON_VALUE(Disk.value, '$.FileSystem'),
        JSON_VALUE(Disk.value, '$.VolumeSerialNumber')
    FROM
        OPENJSON(@Payload, '$.Disks') AS Disk

    OPEN curDisks

    FETCH NEXT FROM curDisks INTO
        @DeviceID,
        @VolumeName,
        @SizeGB,
        @UsedGB,
        @FreeGB,
        @UsedPercent,
        @Description,
        @FileSystem,
        @VolumeSerialNumber

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (
            SELECT
                1
            FROM
                (
                    SELECT TOP 1
                        Hostname,
                        Timestamp,
                        DeviceID,
                        VolumeName,
                        SizeGB,
                        UsedGB,
                        FreeGB,
                        UsedPercent,
                        Description,
                        FileSystem,
                        VolumeSerialNumber
                    FROM
                        dbo.TrendDisks
                    WHERE
                        Hostname = @Hostname
                            AND
                        Timestamp <= @Timestamp
                            AND
                        DeviceID = @DeviceID
                    ORDER BY
                        Timestamp DESC
                ) TrendDisks
            WHERE
                SizeGB = @SizeGB
                    AND
                UsedGB = @UsedGB
                    AND
                FreeGB = @FreeGB
                    AND
                UsedPercent = @UsedPercent
                    AND
                Description = @Description
                    AND
                FileSystem = @FileSystem
                    AND
                VolumeSerialNumber = @VolumeSerialNumber
        )
        BEGIN
            INSERT INTO dbo.TrendDisks
                (
                    Hostname,
                    Timestamp,
                    DeviceID,
                    VolumeName,
                    SizeGB,
                    UsedGB,
                    FreeGB,
                    UsedPercent,
                    Description,
                    FileSystem,
                    VolumeSerialNumber
                )
            VALUES
                (
                    @Hostname,
                    @Timestamp,
                    @DeviceID,
                    @VolumeName,
                    @SizeGB,
                    @UsedGB,
                    @FreeGB,
                    @UsedPercent,
                    @Description,
                    @FileSystem,
                    @VolumeSerialNumber
                )
        END

        FETCH NEXT FROM curDisks INTO
            @DeviceID,
            @VolumeName,
            @SizeGB,
            @UsedGB,
            @FreeGB,
            @UsedPercent,
            @Description,
            @FileSystem,
            @VolumeSerialNumber

    END

    CLOSE curDisks
    DEALLOCATE curDisks
END


GO
