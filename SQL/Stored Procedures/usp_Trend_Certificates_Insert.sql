USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Trend_Certificates_Insert]

	@PayLoad nvarchar(MAX)

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @DnsNameList varchar(MAX),
            @Issuer varchar(MAX),
            @NotBefore datetime,
            @NotAfter datetime,
            @HasPrivateKey bit,
            @SerialNumber varchar(50),
            @Subject varchar(MAX),
            @Thumbprint varchar(50),
			@Template varchar(50),
            @Version float

    SELECT
        @Hostname  = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp = JSON_VALUE(@Payload, '$.Timestamp')

    SET NOCOUNT OFF

    DECLARE curCertificates CURSOR FOR

    SELECT
        JSON_VALUE(Certificate.value, '$.DnsNameList'),
        JSON_VALUE(Certificate.value, '$.Issuer'),
        JSON_VALUE(Certificate.value, '$.NotBefore'),
        JSON_VALUE(Certificate.value, '$.NotAfter'),
        JSON_VALUE(Certificate.value, '$.HasPrivateKey'),
        JSON_VALUE(Certificate.value, '$.SerialNumber'),
        JSON_VALUE(Certificate.value, '$.Subject'),
        JSON_VALUE(Certificate.value, '$.Thumbprint'),
        JSON_VALUE(Certificate.value, '$.Template'),
        JSON_VALUE(Certificate.value, '$.Version')
    FROM
        OPENJSON(@Payload, '$.Certificates') AS Certificate

    OPEN curCertificates

    FETCH NEXT FROM curCertificates INTO
        @DnsNameList,
        @Issuer,
        @NotBefore,
        @NotAfter,
        @HasPrivateKey,
        @SerialNumber,
        @Subject,
        @Thumbprint,
		@Template,
        @Version

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
                        DnsNameList,
                        Issuer,
                        NotBefore,
                        NotAfter,
                        HasPrivateKey,
                        SerialNumber,
                        Subject,
                        Thumbprint,
						Template,
                        Version
                    FROM
                        dbo.TrendCertificates
                    WHERE
                        Hostname = @Hostname
                            AND
                        Timestamp <= @Timestamp
                            AND
                        Thumbprint = @Thumbprint
                    ORDER BY
                        Timestamp DESC
                ) TrendCertificates
            WHERE
                DnsNameList = @DnsNameList
                    AND
                Issuer = @Issuer
                    AND
                NotBefore = @NotBefore
                    AND
                NotAfter = @NotAfter
                    AND
                HasPrivateKey = @HasPrivateKey
                    AND
                SerialNumber = @SerialNumber
                    AND
                Subject = @Subject
                    AND
                Thumbprint = @Thumbprint
                    AND
                ISNULL(Template, '') = ISNULL(@Template, '')
                    AND
                Version = @Version
        )
        BEGIN
            INSERT INTO dbo.TrendCertificates
                (
                    Hostname,
                    Timestamp,
                    DnsNameList,
                    Issuer,
                    NotBefore,
                    NotAfter,
                    HasPrivateKey,
                    SerialNumber,
                    Subject,
                    Thumbprint,
					Template,
                    Version
                )
            VALUES
                (
                    @Hostname,
                    @Timestamp,
                    @DnsNameList,
                    @Issuer,
                    @NotBefore,
                    @NotAfter,
                    @HasPrivateKey,
                    @SerialNumber,
                    @Subject,
                    @Thumbprint,
					@Template,
                    @Version
                )
        END

        FETCH NEXT FROM curCertificates INTO
            @DnsNameList,
            @Issuer,
            @NotBefore,
            @NotAfter,
            @HasPrivateKey,
            @SerialNumber,
            @Subject,
            @Thumbprint,
			@Template,
            @Version
    END

    CLOSE curCertificates
    DEALLOCATE curCertificates

	-- Mark old certificates as Deleted
	UPDATE
		dbo.TrendCertificates
	SET
		Deleted = 1
	WHERE
		Hostname = @Hostname
			AND
		Thumbprint NOT IN (
            SELECT
                JSON_VALUE(Certificate.value, '$.Thumbprint')
            FROM
                OPENJSON(@Payload, '$.Certificates') AS Certificate
		)

END


GO
