package com.ruoyi;

import java.util.Arrays;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.context.ApplicationPidFileWriter;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.util.StringUtils;
import com.ruoyi.desktop.StandaloneDesktopSupport;

/**
 * 鍚姩绋嬪簭
 * 
 * @author ruoyi
 */
@SpringBootApplication(exclude = { DataSourceAutoConfiguration.class })
public class RuoYiApplication
{
    public static void main(String[] args)
    {
        boolean standalone = isStandalone(args);
        if (standalone)
        {
            System.setProperty("java.awt.headless", "false");
        }

        SpringApplication application = new SpringApplication(RuoYiApplication.class);
        String pidFile = System.getProperty("PIDFILE");
        if (StringUtils.hasText(pidFile))
        {
            application.addListeners(new ApplicationPidFileWriter(pidFile));
        }

        ConfigurableApplicationContext context = application.run(args);
        if (standalone)
        {
            StandaloneDesktopSupport.launch(context);
            return;
        }

        System.out.println("(鈾モ棤鈥库棤)锞夛緸  鑻ヤ緷鍚姩鎴愬姛   醿?麓凇`醿?锞? \n" +
                " .-------.       ____     __        \n" +
                " |  _ _   \\      \\   \\   /  /    \n" +
                " | ( ' )  |       \\  _. /  '       \n" +
                " |(_ o _) /        _( )_ .'         \n" +
                " | (_,_).' __  ___(_ o _)'          \n" +
                " |  |\\ \\  |  ||   |(_,_)'         \n" +
                " |  | \\ `'   /|   `-'  /           \n" +
                " |  |  \\    /  \\      /           \n" +
                " ''-'   `'-'    `-..-'              ");
    }

    private static boolean isStandalone(String[] args)
    {
        return Arrays.stream(args)
                .filter(StringUtils::hasText)
                .anyMatch(arg -> arg.contains("standalone"));
    }
}
