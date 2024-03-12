import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.*;

public class TravelAgency extends JFrame {
  private JTextField input;
  private JTextArea sqlQuery;
  private JButton sqlGeneratorButton;
  private JButton executeButton;
  private static JTextArea executionOutput;

  public TravelAgency() {
    super("Travel Agency Chatbot");
    this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

    input = new JTextField(20);
    sqlQuery = new JTextArea(5, 20);
    sqlGeneratorButton = new JButton("Generate SQL Query");
    executeButton = new JButton("Run SQL Query");
    executionOutput = new JTextArea(10, 30);
    executionOutput.setEditable(false);

    setupLayout();

    setupActionListeners();

    this.pack();
    this.setLocationRelativeTo(null);
    this.setVisible(true);
  }

  private void setupLayout() {
    this.setLayout(new BorderLayout());

    JPanel formPanel = new JPanel(new GridBagLayout());
    formPanel.setBorder(BorderFactory.createTitledBorder("Settings"));

    JScrollPane sqlScrollPane = new JScrollPane(sqlQuery);
    sqlScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);

    GridBagConstraints gbc = new GridBagConstraints();
    gbc.insets = new Insets(5, 5, 5, 5);
    gbc.anchor = GridBagConstraints.WEST;

    gbc.gridx = 0;
    gbc.gridy = 0;
    gbc.gridwidth = 1;
    gbc.fill = GridBagConstraints.NONE;
    formPanel.add(new JLabel("Input:"), gbc);

    gbc.gridx = 1;
    gbc.gridy = 0;
    gbc.gridwidth = 2;
    gbc.fill = GridBagConstraints.HORIZONTAL;
    gbc.weightx = 1.0;
    formPanel.add(input, gbc);

    gbc.gridx = 0;
    gbc.gridy = 1;
    gbc.gridwidth = 1;
    gbc.fill = GridBagConstraints.NONE;
    gbc.weightx = 0;
    formPanel.add(new JLabel("SQL Query:"), gbc);

    gbc.gridx = 1;
    gbc.gridy = 1;
    gbc.gridwidth = 2;
    gbc.fill = GridBagConstraints.HORIZONTAL;
    gbc.weightx = 1.0;
    formPanel.add(sqlScrollPane, gbc);

    sqlGeneratorButton.setPreferredSize(new Dimension(150, 30));
    gbc.gridx = 0;
    gbc.gridy = 2;
    gbc.gridwidth = 3;
    gbc.fill = GridBagConstraints.CENTER;
    gbc.anchor = GridBagConstraints.WEST;
    formPanel.add(sqlGeneratorButton, gbc);

    executeButton.setPreferredSize(new Dimension(150, 30));
    gbc.gridx = 2;
    gbc.gridy = 2;
    gbc.gridwidth = 3;
    gbc.fill = GridBagConstraints.CENTER;
    gbc.anchor = GridBagConstraints.EAST;
    formPanel.add(executeButton, gbc);

    this.add(formPanel, BorderLayout.NORTH);

    executionOutput.setEditable(false);
    JScrollPane scrollPane = new JScrollPane(executionOutput);
    scrollPane.setBorder(BorderFactory.createCompoundBorder(
        BorderFactory.createEmptyBorder(10, 10, 10, 10),
        scrollPane.getBorder()));

    this.add(scrollPane, BorderLayout.CENTER);
  }

  private void setupActionListeners() {
    sqlGeneratorButton.addActionListener(new ActionListener() {
      @Override
      public void actionPerformed(ActionEvent e) {
        String inputText = input.getText();
        sqlQuery.setText("");
        executePythonScript(inputText, "", "generate");
      }
    });

    executeButton.addActionListener(new ActionListener() {
      @Override
      public void actionPerformed(ActionEvent e) {
        String sqlQueryText = sqlQuery.getText();
        executePythonScript("", sqlQueryText, "execute");
      }
    });
  }

  public static void main(String[] args) {
    SwingUtilities.invokeLater(TravelAgency::new);
  }

  private static String findPythonPath() {
    String[] commands = {"/bin/bash", "-c", "which python || which python3"};
    ProcessBuilder processBuilder = new ProcessBuilder(commands);
    processBuilder.redirectErrorStream(true);

    try {
      Process process = processBuilder.start();
      try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
        String line = reader.readLine();
        if (line != null && !line.isEmpty()) {
          return line;
        }
      }
      int exitCode = process.waitFor();
      if (exitCode != 0) {
        System.err.println("Error finding Python path");
      }
    } catch (IOException | InterruptedException e) {
      e.printStackTrace();
    }
    return "python";
  }

  private void executePythonScript(String inputText, String sqlQueryText, String executionType) {
    try {
      String scriptName = "SqlGeneratorScript.py";
      File tempScript = extractScriptFromJar(scriptName);
      tempScript.setExecutable(true);

      String pythonPath = findPythonPath();
      String databasePath = "/Users/hunnybalani/Desktop/Rutgers/Sem4/DB/Travel-Agency-Management-System/database";

      ProcessBuilder processBuilder = new ProcessBuilder(pythonPath, tempScript.getAbsolutePath(), inputText, sqlQueryText, executionType, databasePath);
      processBuilder.redirectErrorStream(true);

      Process process = processBuilder.start();
      BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));

      String line;
      while ((line = reader.readLine()) != null) {
        if (executionType == "generate")
          sqlQuery.append(line + "\n");
        else
          executionOutput.append(line + "\n");
      }

      int exitCode = process.waitFor();
      if (exitCode != 0) {
        executionOutput.append("Script execution failed with exit code: " + exitCode + "\n");
      }
    } catch (InterruptedException | IOException e) {
      executionOutput.append(e.getMessage());
    }
  }

  private static File extractScriptFromJar(String scriptName) throws IOException {
    InputStream inputStream = TravelAgency.class.getResourceAsStream("/" + scriptName);
    if (inputStream == null) {
      throw new IOException("Script file not found in JAR: " + scriptName);
    }

    File tempFile = File.createTempFile("SqlGeneratorScript", ".py");
    try (OutputStream outputStream = new FileOutputStream(tempFile)) {
      byte[] buffer = new byte[1024];
      int bytesRead;
      while ((bytesRead = inputStream.read(buffer)) != -1) {
        outputStream.write(buffer, 0, bytesRead);
      }
    }
    return tempFile;
  }

}