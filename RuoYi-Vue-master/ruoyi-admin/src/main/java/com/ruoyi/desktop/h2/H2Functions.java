package com.ruoyi.desktop.h2;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Date;

public final class H2Functions
{
    private H2Functions()
    {
    }

    public static String dateFormat(Object value, String mysqlPattern)
    {
        if (value == null)
        {
            return null;
        }

        LocalDateTime dateTime;
        if (value instanceof Timestamp)
        {
            dateTime = ((Timestamp) value).toLocalDateTime();
        }
        else if (value instanceof Date)
        {
            dateTime = LocalDateTime.ofInstant(((Date) value).toInstant(), ZoneId.systemDefault());
        }
        else if (value instanceof LocalDateTime)
        {
            dateTime = (LocalDateTime) value;
        }
        else if (value instanceof LocalDate)
        {
            dateTime = ((LocalDate) value).atStartOfDay();
        }
        else
        {
            return String.valueOf(value);
        }

        String javaPattern = mysqlPattern
                .replace("%Y", "yyyy")
                .replace("%m", "MM")
                .replace("%d", "dd")
                .replace("%H", "HH")
                .replace("%i", "mm")
                .replace("%s", "ss");
        return dateTime.format(DateTimeFormatter.ofPattern(javaPattern));
    }

    public static Integer findInSet(String target, String csv)
    {
        if (target == null || csv == null || csv.isEmpty())
        {
            return 0;
        }
        String[] items = csv.split(",");
        for (int i = 0; i < items.length; i++)
        {
            if (target.equals(items[i].trim()))
            {
                return i + 1;
            }
        }
        return 0;
    }
}
