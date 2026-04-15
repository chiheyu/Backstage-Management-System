package com.ruoyi.desktop;

import java.awt.BorderLayout;
import java.awt.Desktop;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.GraphicsEnvironment;
import java.awt.GridLayout;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.IOException;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.concurrent.atomic.AtomicBoolean;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;

public final class StandaloneDesktopSupport
{
    private static final Logger log = LoggerFactory.getLogger(StandaloneDesktopSupport.class);

    private static final AtomicBoolean LAUNCHED = new AtomicBoolean(false);

    private StandaloneDesktopSupport()
    {
    }

    public static void launch(ConfigurableApplicationContext context)
    {
        if (!LAUNCHED.compareAndSet(false, true))
        {
            return;
        }

        if (GraphicsEnvironment.isHeadless())
        {
            openBrowserIfNecessary(context);
            return;
        }

        SwingUtilities.invokeLater(() -> {
            StandaloneControlFrame frame = new StandaloneControlFrame(context);
            frame.setVisible(true);
            frame.openBrowserIfNecessary();
        });
    }

    private static void openBrowserIfNecessary(ConfigurableApplicationContext context)
    {
        Environment environment = context.getEnvironment();
        boolean autoOpenBrowser = environment.getProperty("app.desktop.auto-open-browser", Boolean.class, true);
        if (!autoOpenBrowser)
        {
            return;
        }
        openUrl(resolveBaseUrl(environment));
    }

    private static String resolveBaseUrl(Environment environment)
    {
        String port = environment.getProperty("local.server.port", environment.getProperty("server.port", "18080"));
        return "http://127.0.0.1:" + port + "/";
    }

    private static Path resolveDataDirectory(Environment environment)
    {
        String appHome = environment.getProperty("app.home", System.getProperty("user.dir"));
        return Paths.get(appHome, "data");
    }

    private static void openUrl(String url)
    {
        try
        {
            if (Desktop.isDesktopSupported() && Desktop.getDesktop().isSupported(Desktop.Action.BROWSE))
            {
                Desktop.getDesktop().browse(URI.create(url));
                return;
            }
            new ProcessBuilder("cmd", "/c", "start", "", url).start();
        }
        catch (Exception ex)
        {
            log.warn("鎵撳紑娴忚鍣ㄥけ璐?{}", ex.getMessage());
        }
    }

    private static void openDirectory(Path directory)
    {
        try
        {
            Files.createDirectories(directory);
            if (Desktop.isDesktopSupported() && Desktop.getDesktop().isSupported(Desktop.Action.OPEN))
            {
                Desktop.getDesktop().open(directory.toFile());
                return;
            }
            new ProcessBuilder("explorer.exe", directory.toAbsolutePath().toString()).start();
        }
        catch (IOException ex)
        {
            log.warn("鎵撳紑鏁版嵁鐩綍澶辫触: {}", ex.getMessage());
        }
    }

    private static void shutdown(ConfigurableApplicationContext context)
    {
        new Thread(() -> {
            int exitCode = SpringApplication.exit(context);
            System.exit(exitCode);
        }, "standalone-exit").start();
    }

    private static final class StandaloneControlFrame extends JFrame
    {
        private final ConfigurableApplicationContext context;

        private final Environment environment;

        private final String baseUrl;

        private final Path dataDirectory;

        private boolean browserOpened;

        private StandaloneControlFrame(ConfigurableApplicationContext context)
        {
            this.context = context;
            this.environment = context.getEnvironment();
            this.baseUrl = resolveBaseUrl(environment);
            this.dataDirectory = resolveDataDirectory(environment);

            setTitle(environment.getProperty("app.desktop.window-title", "汉中售后一体化桌面版"));
            setSize(520, 220);
            setLocationRelativeTo(null);
            setResizable(false);
            setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);

            addWindowListener(new WindowAdapter()
            {
                @Override
                public void windowClosing(WindowEvent e)
                {
                    int result = JOptionPane.showConfirmDialog(
                            StandaloneControlFrame.this,
                            "关闭桌面窗口会同时停止后端服务，是否继续？",
                            "退出确认",
                            JOptionPane.YES_NO_OPTION);
                    if (result == JOptionPane.YES_OPTION)
                    {
                        dispose();
                        shutdown(context);
                    }
                }
            });

            initLayout();
        }

        private void initLayout()
        {
            JPanel content = new JPanel(new BorderLayout(0, 16));
            content.setBorder(BorderFactory.createEmptyBorder(18, 18, 18, 18));

            JLabel title = new JLabel("汉中售后一体化桌面版已启动");
            title.setFont(new Font("Microsoft YaHei", Font.BOLD, 20));
            content.add(title, BorderLayout.NORTH);

            JPanel infoPanel = new JPanel(new GridLayout(3, 1, 0, 8));
            infoPanel.add(new JLabel("访问地址：" + baseUrl));
            infoPanel.add(new JLabel("数据目录：" + dataDirectory.toAbsolutePath()));
            infoPanel.add(new JLabel("关闭当前窗口即可安全停止全部服务"));
            content.add(infoPanel, BorderLayout.CENTER);

            JPanel actions = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 0));

            JButton openSystemButton = new JButton("打开系统");
            openSystemButton.addActionListener(event -> openUrl(baseUrl));
            actions.add(openSystemButton);

            JButton openDataButton = new JButton("打开数据目录");
            openDataButton.addActionListener(event -> openDirectory(dataDirectory));
            actions.add(openDataButton);

            JButton exitButton = new JButton("退出程序");
            exitButton.addActionListener(event -> dispatchEvent(new WindowEvent(this, WindowEvent.WINDOW_CLOSING)));
            actions.add(exitButton);

            content.add(actions, BorderLayout.SOUTH);
            setContentPane(content);
        }

        private void openBrowserIfNecessary()
        {
            if (browserOpened)
            {
                return;
            }
            browserOpened = true;
            if (environment.getProperty("app.desktop.auto-open-browser", Boolean.class, true))
            {
                openUrl(baseUrl);
            }
        }
    }
}
