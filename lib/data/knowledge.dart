import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Sample private library for a Machine Learning student. Every answer, search
// result, explanation and question in the app is grounded in these passages.
// When the AI backend is connected, uploads are parsed into the same shapes.

enum DocType {
  book('Book', Icons.menu_book_outlined),
  notes('Notes', Icons.edit_note),
  slides('Slides', Icons.slideshow_outlined),
  paper('Paper', Icons.article_outlined),
  pastExam('Past exam', Icons.assignment_outlined);

  const DocType(this.label, this.icon);

  final String label;
  final IconData icon;
  /// Every document type uses the current accent colour.
  Color get color => AppColors.brand;
}

class LibraryDoc {
  const LibraryDoc({
    required this.id,
    required this.title,
    required this.type,
    required this.course,
    required this.pages,
    required this.added,
    this.indexed = true,
  });

  final String id;
  final String title;
  final DocType type;
  final String course;
  final int pages;
  final String added;

  /// False for uploads that still need the AI backend to parse and index them.
  final bool indexed;
}

class Passage {
  const Passage({
    required this.id,
    required this.docId,
    required this.page,
    required this.section,
    required this.concepts,
    required this.text,
  });

  final String id;
  final String docId;
  final int page;
  final String section;
  final List<String> concepts;
  final String text;
}

class Concept {
  const Concept({
    required this.id,
    required this.name,
    required this.simple,
    required this.standard,
    required this.deep,
    required this.example,
    required this.keyPassage,
  });

  final String id;
  final String name;
  final String simple;
  final String standard;
  final String deep;
  final String example;
  final String keyPassage;

  String explanation(int level) => switch (level) {
        0 => simple,
        2 => deep,
        _ => standard,
      };
}

class ConceptLink {
  const ConceptLink(this.from, this.to, this.how);

  final String from;
  final String to;
  final String how;
}

/// What a question tests. Error analysis groups mistakes by this.
enum QuestionKind {
  definition('Knowing definitions', 'Recalling what a term means'),
  application('Applying a rule', 'Using a rule in a concrete situation'),
  reasoning('Reasoning about cause and effect', 'Explaining why something happens');

  const QuestionKind(this.label, this.description);

  final String label;
  final String description;
}

class QuizQuestion {
  const QuizQuestion({
    required this.conceptId,
    required this.kind,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
    required this.passageId,
  });

  final QuestionKind kind;
  final String conceptId;
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;
  final String passageId;
}

class SocraticStep {
  const SocraticStep(this.question, this.hint);

  final String question;
  final String hint;
}

class SocraticScript {
  const SocraticScript({
    required this.conceptId,
    required this.opening,
    required this.steps,
    required this.conclusion,
  });

  final String conceptId;
  final String opening;
  final List<SocraticStep> steps;
  final String conclusion;
}

class SourceView {
  const SourceView(this.passageId, this.claim);

  final String passageId;
  final String claim;
}

/// One marking point for a written exam answer.
class RubricPoint {
  const RubricPoint(this.text, this.keywords, this.passageId, this.marks);

  final String text;

  /// The point counts as covered if the answer mentions any of these.
  final List<String> keywords;
  final String passageId;
  final int marks;
}

/// A past-exam question with marking points drawn from the course materials.
class RubricQuestion {
  const RubricQuestion({required this.passageId, required this.conceptId, required this.points});

  final String passageId;
  final String conceptId;
  final List<RubricPoint> points;

  int get marks => points.fold(0, (sum, p) => sum + p.marks);
}

class Comparison {
  const Comparison({
    required this.conceptId,
    required this.views,
    required this.agreement,
    required this.difference,
  });

  final String conceptId;
  final List<SourceView> views;
  final String agreement;
  final String difference;
}

// ─── Library ────────────────────────────────────────────────────────────────

const sampleDocs = <LibraryDoc>[
  LibraryDoc(
    id: 'dlf',
    title: 'Deep Learning Foundations',
    type: DocType.book,
    course: 'Neural Networks Fundamentals',
    pages: 412,
    added: '3 weeks ago',
  ),
  LibraryDoc(
    id: 'lec5',
    title: 'Lecture 5: Optimisation',
    type: DocType.slides,
    course: 'Neural Networks Fundamentals',
    pages: 38,
    added: '6 days ago',
  ),
  LibraryDoc(
    id: 'notes6',
    title: 'My notes: Week 6',
    type: DocType.notes,
    course: 'Neural Networks Fundamentals',
    pages: 6,
    added: '4 days ago',
  ),
  LibraryDoc(
    id: 'la',
    title: 'Linear Algebra for ML',
    type: DocType.book,
    course: 'Linear Algebra for ML',
    pages: 296,
    added: '2 months ago',
  ),
  LibraryDoc(
    id: 'gen',
    title: 'Generalisation in Practice',
    type: DocType.paper,
    course: 'Neural Networks Fundamentals',
    pages: 14,
    added: '2 weeks ago',
  ),
  LibraryDoc(
    id: 'exam25',
    title: 'Past exam: Machine Learning 2025',
    type: DocType.pastExam,
    course: 'Neural Networks Fundamentals',
    pages: 9,
    added: 'Yesterday',
  ),
  LibraryDoc(
    id: 'exam24',
    title: 'Past exam: Machine Learning 2024',
    type: DocType.pastExam,
    course: 'Neural Networks Fundamentals',
    pages: 8,
    added: 'Yesterday',
  ),
];

const passages = <Passage>[
  Passage(
    id: 'p1',
    docId: 'dlf',
    page: 87,
    section: '4.2 Gradient descent',
    concepts: ['gd', 'loss'],
    text: 'Gradient descent minimises a loss function by repeatedly moving the parameters a '
        'small step in the direction of the negative gradient. Each step uses the slope of the '
        'loss at the current point, so the algorithm walks downhill until the slope is close to '
        'zero.',
  ),
  Passage(
    id: 'p2',
    docId: 'dlf',
    page: 89,
    section: '4.3 Choosing a learning rate',
    concepts: ['lr', 'gd'],
    text: 'The learning rate sets the size of each gradient step. A rate that is too large makes '
        'the loss oscillate or diverge; a rate that is too small makes training slow and can '
        'leave the model stuck on a plateau. Many practitioners start around 0.001 and adjust '
        'from the training curve.',
  ),
  Passage(
    id: 'p3',
    docId: 'lec5',
    page: 12,
    section: 'Slide 12: Step size',
    concepts: ['lr'],
    text: 'Learning rate rule of thumb: if the loss jumps around, halve the rate; if it barely '
        'moves after many epochs, double it. Learning-rate schedules lower the rate as training '
        'progresses.',
  ),
  Passage(
    id: 'p4',
    docId: 'lec5',
    page: 15,
    section: 'Slide 15: Mini-batches',
    concepts: ['gd'],
    text: 'Stochastic gradient descent estimates the gradient from a small mini-batch instead of '
        'the full dataset. The estimate is noisy, but each step is much cheaper, and the noise '
        'can help the model escape poor regions.',
  ),
  Passage(
    id: 'p5',
    docId: 'dlf',
    page: 112,
    section: '5.1 Backpropagation',
    concepts: ['backprop', 'gd'],
    text: 'Backpropagation computes the gradient of the loss with respect to every weight by '
        'applying the chain rule layer by layer, starting from the output and moving backwards. '
        'Gradient descent then uses these gradients to update the weights.',
  ),
  Passage(
    id: 'p6',
    docId: 'notes6',
    page: 2,
    section: 'Backprop in my own words',
    concepts: ['backprop', 'loss'],
    text: 'Forward pass: compute the predictions and the loss. Backward pass: work out how much '
        'each weight contributed to the error, reusing the result from the layer after it. That '
        'reuse is why backprop is fast.',
  ),
  Passage(
    id: 'p7',
    docId: 'dlf',
    page: 64,
    section: '3.4 Loss functions',
    concepts: ['loss'],
    text: "A loss function measures how far the model's predictions are from the true values. "
        'Mean squared error suits regression; cross-entropy suits classification because it '
        'heavily penalises confident wrong answers.',
  ),
  Passage(
    id: 'p8',
    docId: 'gen',
    page: 3,
    section: '2 Overfitting',
    concepts: ['overfitting'],
    text: 'A model overfits when it learns noise in the training data as if it were signal. '
        'Training error keeps falling while validation error starts to rise; the gap between '
        'the two curves is the clearest warning sign.',
  ),
  Passage(
    id: 'p9',
    docId: 'dlf',
    page: 158,
    section: '7.1 Generalisation',
    concepts: ['overfitting', 'regularization'],
    text: 'Overfitting is most likely when the model has many parameters relative to the amount '
        'of training data. More data, simpler models and regularisation all reduce it.',
  ),
  Passage(
    id: 'p10',
    docId: 'gen',
    page: 6,
    section: '3 Regularisation methods',
    concepts: ['regularization', 'loss'],
    text: 'L2 regularisation adds a penalty proportional to the squared weights to the loss, '
        'pushing the model towards smaller weights. Dropout randomly disables units during '
        'training. In our experiments dropout helped large networks more than L2 did.',
  ),
  Passage(
    id: 'p11',
    docId: 'dlf',
    page: 163,
    section: '7.3 Weight decay',
    concepts: ['regularization'],
    text: 'Weight decay, equivalent to L2 regularisation for plain gradient descent, is usually '
        'the first regulariser to try. Dropout is useful but should not be the default for small '
        'networks.',
  ),
  Passage(
    id: 'p12',
    docId: 'la',
    page: 141,
    section: '6.1 Eigenvectors',
    concepts: ['eigen'],
    text: 'An eigenvector of a matrix A is a non-zero vector v whose direction does not change '
        'when A is applied: Av = λv. The scalar λ is the eigenvalue and tells you how much v is '
        'stretched.',
  ),
  Passage(
    id: 'p13',
    docId: 'la',
    page: 158,
    section: '6.4 Principal component analysis',
    concepts: ['pca', 'eigen'],
    text: "Principal component analysis finds the eigenvectors of the data's covariance matrix. "
        'The eigenvectors with the largest eigenvalues point in the directions of greatest '
        'variance, so keeping only those reduces dimensions while preserving most information.',
  ),
  Passage(
    id: 'p14',
    docId: 'notes6',
    page: 5,
    section: 'PCA cheat sheet',
    concepts: ['pca', 'overfitting'],
    text: 'PCA means rotating the data onto the directions with the most spread, then dropping '
        'the rest. Fewer features can also reduce overfitting.',
  ),
  Passage(
    id: 'p15',
    docId: 'exam25',
    page: 2,
    section: 'Question 3 (12 marks)',
    concepts: ['lr', 'gd'],
    text: 'Explain the effect of the learning rate on gradient descent. Sketch the training loss '
        'for a rate that is too high and for one that is too low.',
  ),
  Passage(
    id: 'p16',
    docId: 'exam25',
    page: 5,
    section: 'Question 7 (15 marks)',
    concepts: ['overfitting', 'regularization'],
    text: 'A network reaches 99% training accuracy and 71% validation accuracy. Diagnose the '
        'problem and propose two remedies, justifying each.',
  ),
  Passage(
    id: 'p17',
    docId: 'exam24',
    page: 2,
    section: 'Question 2 (10 marks)',
    concepts: ['lr', 'gd'],
    text: 'Describe what happens to training when the learning rate is too high. Suggest one way '
        'to choose a better value.',
  ),
  Passage(
    id: 'p18',
    docId: 'exam24',
    page: 4,
    section: 'Question 5 (14 marks)',
    concepts: ['backprop', 'loss'],
    text: 'Explain how backpropagation uses the chain rule to compute gradients in a two-layer '
        'network.',
  ),
  Passage(
    id: 'p19',
    docId: 'exam24',
    page: 6,
    section: 'Question 8 (12 marks)',
    concepts: ['overfitting', 'regularization'],
    text: 'Explain how L2 regularisation reduces overfitting. Use a diagram of training and '
        'validation error to support your answer.',
  ),
];

const rubrics = <RubricQuestion>[
  RubricQuestion(
    passageId: 'p15',
    conceptId: 'lr',
    points: [
      RubricPoint('Says the learning rate sets the size of each gradient step', ['step', 'size'], 'p2', 3),
      RubricPoint('Too high: the loss oscillates or diverges', ['oscillat', 'diverg', 'jump', 'overshoot', 'unstable'], 'p2', 3),
      RubricPoint('Too low: training is slow or stalls on a plateau', ['slow', 'stall', 'plateau', 'stuck'], 'p2', 3),
      RubricPoint('Describes the training loss curve for each case', ['curve', 'sketch', 'graph', 'plot'], 'p15', 3),
    ],
  ),
  RubricQuestion(
    passageId: 'p16',
    conceptId: 'overfitting',
    points: [
      RubricPoint('Diagnoses overfitting from the training/validation gap', ['overfit'], 'p8', 5),
      RubricPoint(
        'Proposes regularisation (L2, weight decay or dropout) and says why it helps',
        ['regularis', 'regulariz', 'weight decay', 'l2', 'dropout'],
        'p10',
        5,
      ),
      RubricPoint(
        'Proposes more data, a simpler model or early stopping and says why it helps',
        ['more data', 'augment', 'simpler', 'smaller', 'early stop', 'fewer parameters'],
        'p9',
        5,
      ),
    ],
  ),
];

/// Kinds of exam question, recognised by their command word.
const examCommandWords = <String, List<String>>{
  'Explain': ['explain'],
  'Describe': ['describe'],
  'Diagram / sketch': ['sketch', 'diagram'],
  'Diagnose': ['diagnose'],
  'Propose / suggest': ['propose', 'suggest'],
};

// ─── Concepts ───────────────────────────────────────────────────────────────

const concepts = <Concept>[
  Concept(
    id: 'gd',
    name: 'Gradient descent',
    keyPassage: 'p1',
    simple: 'Imagine standing on a foggy hill and wanting to reach the bottom. You feel which '
        'way the ground slopes and take a small step downhill, again and again. Gradient '
        "descent does the same with a model's error.",
    standard: 'Gradient descent lowers a loss function by repeatedly nudging every parameter in '
        'the direction that reduces the loss fastest: the negative gradient. The learning rate '
        'sets the step size, and training settles when the slope is close to zero.',
    deep: 'For parameters θ and loss L(θ), each update is θ ← θ − η∇L(θ). Full-batch descent '
        'uses the exact gradient; stochastic and mini-batch variants estimate it from samples, '
        'trading noise for much cheaper steps. On non-convex losses it reaches a local minimum '
        'or a flat saddle region, so initialisation, η and schedules all shape where training '
        'ends.',
    example: 'Fitting y = wx to points where the best w is 2: starting at w = 0, each step moves '
        'w toward 2, quickly at first and then more slowly as the slope of the error flattens.',
  ),
  Concept(
    id: 'lr',
    name: 'Learning rate',
    keyPassage: 'p2',
    simple: 'The learning rate is how big each step downhill is. Big steps are fast but can '
        'overshoot; tiny steps are safe but slow.',
    standard: 'The learning rate η scales each gradient step. Too high and the loss oscillates '
        'or diverges; too low and training crawls or stalls on plateaus. Tune it by watching the '
        'training loss, and lower it over time with a schedule.',
    deep: 'Stability depends on the curvature of the loss: for a quadratic whose largest '
        'curvature is λmax, plain gradient descent diverges when η > 2/λmax. Schedules (step '
        'decay, cosine, warm-up) and adaptive optimisers adjust the effective step per parameter '
        'to balance speed and stability.',
    example: 'With η = 1.0 the loss jumps between 0.9 and 2.3 every epoch; with η = 0.001 it '
        'drops from 0.90 to 0.89 in ten epochs; with η = 0.05 it falls smoothly to 0.20.',
  ),
  Concept(
    id: 'backprop',
    name: 'Backpropagation',
    keyPassage: 'p5',
    simple: 'After the model makes a mistake, backpropagation works out how much each '
        'connection was to blame, starting from the end and working backwards.',
    standard: 'Backpropagation computes the gradient of the loss for every weight using the '
        'chain rule, layer by layer from the output back to the input. Each layer reuses the '
        'result from the layer after it, which makes it efficient. Gradient descent then uses '
        'these gradients.',
    deep: 'Backpropagation is reverse-mode automatic differentiation: one backward pass gives '
        '∂L/∂w for every weight at roughly the cost of a forward pass. Each layer passes back '
        'δ = ∂L/∂z and computes its weight gradient as δ times its input. Vanishing or exploding '
        'gradients appear when these products shrink or grow across many layers.',
    example: 'In a two-layer network the output error is computed first. Multiplied by the '
        'output weights, it tells the hidden layer its share of the blame, and each hidden '
        "weight's gradient is that share times the weight's input.",
  ),
  Concept(
    id: 'loss',
    name: 'Loss function',
    keyPassage: 'p7',
    simple: 'A loss function is a score of how wrong the model is. Lower is better, and '
        'training tries to make it as low as possible.',
    standard: 'A loss function measures the gap between predictions and true values. Mean '
        'squared error is common for regression; cross-entropy for classification, because it '
        'strongly penalises confident wrong answers. Gradient descent minimises it.',
    deep: 'The loss defines the optimisation problem: mean squared error corresponds to maximum '
        'likelihood under Gaussian noise, cross-entropy to maximum likelihood for categorical '
        'outputs. Its shape (convexity, smoothness, scale) decides how easy training is, and '
        'regularisation terms are added directly to it.',
    example: 'Predicting 0.9 for the true class gives a cross-entropy of −ln 0.9 ≈ 0.11. '
        'Predicting 0.1 gives −ln 0.1 ≈ 2.30, a far larger penalty.',
  ),
  Concept(
    id: 'overfitting',
    name: 'Overfitting',
    keyPassage: 'p8',
    simple: 'Overfitting is memorising the practice questions instead of learning the subject. '
        'The model does well on data it has seen and badly on new data.',
    standard: 'A model overfits when it learns noise in the training data as if it were a '
        'pattern. The warning sign is training error falling while validation error rises. It '
        'is most likely with many parameters and little data.',
    deep: 'Overfitting is high variance: the fitted function depends strongly on the particular '
        'training sample. Capacity relative to data size, training length and label noise drive '
        'it. Remedies reduce effective capacity (regularisation, smaller models, early stopping) '
        'or add data (collection, augmentation).',
    example: '99% training accuracy with 71% validation accuracy is a 28-point gap: a classic '
        'overfitting pattern, like Question 7 in your past exam.',
  ),
  Concept(
    id: 'regularization',
    name: 'Regularisation',
    keyPassage: 'p10',
    simple: 'Regularisation is a rule that stops a model getting too complicated, so it learns '
        'general patterns instead of memorising.',
    standard: 'Regularisation adds constraints that reduce overfitting. L2 (weight decay) adds a '
        'penalty on large weights to the loss; dropout randomly switches off units during '
        'training so the network cannot rely on any single one.',
    deep: 'L2 adds λ‖w‖² to the loss, shrinking weights every step (the same as weight decay '
        'under plain SGD, but not under Adam). Dropout trains an implicit ensemble of '
        'sub-networks. Early stopping, augmentation and smaller architectures also regularise; '
        'λ and the dropout rate are tuned on validation data.',
    example: 'Adding L2 with λ = 0.01 to the 99% / 71% network might give 94% training and 85% '
        'validation accuracy: slightly worse on seen data, much better on new data.',
  ),
  Concept(
    id: 'eigen',
    name: 'Eigenvectors',
    keyPassage: 'p12',
    simple: 'Some arrows only get longer or shorter when a transformation is applied, never '
        'turned. Those special arrows are eigenvectors.',
    standard: 'An eigenvector v of a matrix A satisfies Av = λv: applying A only stretches v by '
        'the eigenvalue λ without changing its direction. Eigenvectors reveal the natural axes '
        'of a transformation.',
    deep: 'Eigenpairs solve det(A − λI) = 0. A symmetric matrix has real eigenvalues and '
        'orthogonal eigenvectors, so it can be diagonalised as A = QΛQᵀ. That is why covariance '
        'matrices, which are symmetric, give orthogonal principal components.',
    example: 'For A = [[2, 0], [0, 3]], the vector v = (1, 0) gives Av = (2, 0) = 2v, so v is an '
        'eigenvector with eigenvalue 2.',
  ),
  Concept(
    id: 'pca',
    name: 'Principal component analysis',
    keyPassage: 'p13',
    simple: 'PCA finds the directions in which your data spreads out most, then lets you keep '
        'just those, like describing a long thin cloud of points by its length alone.',
    standard: "Principal component analysis finds the eigenvectors of the data's covariance "
        'matrix. Components with the largest eigenvalues capture the most variance, so keeping '
        'the top few reduces dimensions while preserving most information.',
    deep: 'After centring X, PCA diagonalises the covariance C = XᵀX / (n − 1); equivalently it '
        'takes the SVD X = UΣVᵀ, whose right singular vectors are the components. The share of '
        'variance kept guides how many components to retain. PCA is linear and sensitive to '
        'feature scaling.',
    example: "Height and arm span are strongly correlated. PCA's first component, roughly "
        "'body size', may hold 95% of the variance, so two features become one.",
  ),
];

const conceptLinks = <ConceptLink>[
  ConceptLink('loss', 'gd', 'Gradient descent is the method that makes the loss function smaller.'),
  ConceptLink('gd', 'lr', 'The learning rate sets how far each gradient descent step moves.'),
  ConceptLink('backprop', 'gd', 'Backpropagation supplies the gradients that gradient descent uses.'),
  ConceptLink('backprop', 'loss', 'Backpropagation starts from the loss and traces it back to each weight.'),
  ConceptLink('overfitting', 'regularization', 'Regularisation is the main family of fixes for overfitting.'),
  ConceptLink('regularization', 'loss', 'L2 regularisation works by adding a penalty term to the loss.'),
  ConceptLink('eigen', 'pca', "PCA's components are the eigenvectors of the covariance matrix."),
  ConceptLink('pca', 'overfitting', 'Your notes (p. 5) say fewer features from PCA can reduce overfitting.'),
];

// ─── Questions, recall and Socratic scripts ─────────────────────────────────

const questionBank = <QuizQuestion>[
  QuizQuestion(
    conceptId: 'gd',
    kind: QuestionKind.definition,
    question: 'In which direction does gradient descent move the parameters?',
    options: ['Along the gradient', 'Opposite to the gradient', 'In a random direction'],
    answer: 1,
    explanation: 'It steps along the negative gradient, the direction in which the loss falls fastest.',
    passageId: 'p1',
  ),
  QuizQuestion(
    conceptId: 'gd',
    kind: QuestionKind.reasoning,
    question: 'Why use mini-batches instead of the full dataset?',
    options: [
      'Each step is much cheaper',
      'The gradient becomes exact',
      'It removes the need for a learning rate',
    ],
    answer: 0,
    explanation: 'A mini-batch gives a noisy but far cheaper estimate of the gradient.',
    passageId: 'p4',
  ),
  QuizQuestion(
    conceptId: 'lr',
    kind: QuestionKind.application,
    question: 'The training loss jumps up and down every epoch. What should you try first?',
    options: ['Raise the learning rate', 'Lower the learning rate', 'Add more layers'],
    answer: 1,
    explanation: 'Your slides say: if the loss jumps around, halve the rate.',
    passageId: 'p3',
  ),
  QuizQuestion(
    conceptId: 'lr',
    kind: QuestionKind.reasoning,
    question: 'What happens when the learning rate is far too small?',
    options: ['Training diverges', 'Training is very slow or stalls', 'The model overfits at once'],
    answer: 1,
    explanation: 'Tiny steps make training slow and can leave the model stuck on a plateau.',
    passageId: 'p2',
  ),
  QuizQuestion(
    conceptId: 'backprop',
    kind: QuestionKind.definition,
    question: 'What does backpropagation compute?',
    options: [
      'The gradient of the loss for every weight',
      "The model's predictions",
      'The best learning rate',
    ],
    answer: 0,
    explanation: 'It computes gradients; gradient descent then uses them to update the weights.',
    passageId: 'p5',
  ),
  QuizQuestion(
    conceptId: 'backprop',
    kind: QuestionKind.definition,
    question: 'Which rule of calculus is backpropagation built on?',
    options: ['The product rule', 'The chain rule', 'The quotient rule'],
    answer: 1,
    explanation: 'It applies the chain rule layer by layer from the output backwards.',
    passageId: 'p5',
  ),
  QuizQuestion(
    conceptId: 'loss',
    kind: QuestionKind.application,
    question: 'Which loss is usually used for classification?',
    options: ['Mean squared error', 'Cross-entropy', 'Mean absolute error'],
    answer: 1,
    explanation: 'Cross-entropy heavily penalises confident wrong answers, which suits classification.',
    passageId: 'p7',
  ),
  QuizQuestion(
    conceptId: 'loss',
    kind: QuestionKind.definition,
    question: 'What does a loss function measure?',
    options: [
      'How far predictions are from the true values',
      'How many layers the model has',
      'How long training takes',
    ],
    answer: 0,
    explanation: 'It scores the gap between predictions and the truth.',
    passageId: 'p7',
  ),
  QuizQuestion(
    conceptId: 'overfitting',
    kind: QuestionKind.application,
    question: 'Training error falls while validation error rises. What is happening?',
    options: ['Underfitting', 'Overfitting', 'A bug in the learning rate'],
    answer: 1,
    explanation: 'The growing gap between the two curves is the clearest sign of overfitting.',
    passageId: 'p8',
  ),
  QuizQuestion(
    conceptId: 'overfitting',
    kind: QuestionKind.reasoning,
    question: 'Which situation makes overfitting most likely?',
    options: ['Many parameters, little data', 'Few parameters, lots of data', 'Normalised inputs'],
    answer: 0,
    explanation: 'Overfitting is most likely with many parameters relative to the training data.',
    passageId: 'p9',
  ),
  QuizQuestion(
    conceptId: 'regularization',
    kind: QuestionKind.definition,
    question: 'How does L2 regularisation work?',
    options: [
      'It adds a penalty on large weights to the loss',
      'It removes layers from the network',
      'It raises the learning rate',
    ],
    answer: 0,
    explanation: 'The penalty on squared weights pushes the model towards smaller weights.',
    passageId: 'p10',
  ),
  QuizQuestion(
    conceptId: 'regularization',
    kind: QuestionKind.application,
    question: 'According to your textbook, which regulariser should you try first?',
    options: ['Dropout', 'Weight decay', 'Early stopping'],
    answer: 1,
    explanation: 'The book calls weight decay the usual first choice.',
    passageId: 'p11',
  ),
  QuizQuestion(
    conceptId: 'eigen',
    kind: QuestionKind.definition,
    question: 'If Av = λv for a non-zero vector v, what is λ?',
    options: ['An eigenvector', 'An eigenvalue', 'The determinant'],
    answer: 1,
    explanation: 'λ is the eigenvalue: how much the eigenvector v is stretched.',
    passageId: 'p12',
  ),
  QuizQuestion(
    conceptId: 'eigen',
    kind: QuestionKind.definition,
    question: 'What happens to an eigenvector when the matrix is applied?',
    options: ['It rotates by 90°', 'It keeps its direction and is scaled', 'It becomes zero'],
    answer: 1,
    explanation: 'Its direction does not change; it is only stretched or shrunk.',
    passageId: 'p12',
  ),
  QuizQuestion(
    conceptId: 'pca',
    kind: QuestionKind.application,
    question: 'Which components does PCA keep to preserve most information?',
    options: ['Those with the smallest eigenvalues', 'Those with the largest eigenvalues', 'Random ones'],
    answer: 1,
    explanation: 'The largest eigenvalues mark the directions of greatest variance.',
    passageId: 'p13',
  ),
  QuizQuestion(
    conceptId: 'pca',
    kind: QuestionKind.definition,
    question: 'PCA finds the eigenvectors of which matrix?',
    options: ['The covariance matrix', 'The weight matrix', 'The identity matrix'],
    answer: 0,
    explanation: "PCA works on the data's covariance matrix.",
    passageId: 'p13',
  ),
];

const socraticScripts = <SocraticScript>[
  SocraticScript(
    conceptId: 'gd',
    opening: "Let's work out gradient descent together. I'll ask questions instead of giving the answer.",
    steps: [
      SocraticStep(
        'You are on a hill in thick fog and want to get down. How would you decide which way to step?',
        "You can't see the bottom, only the slope under your feet.",
      ),
      SocraticStep(
        'In a model, what plays the role of the height of the hill?',
        'Think about the number we want to make as small as possible.',
      ),
      SocraticStep(
        'What would happen if every step you took were enormous?',
        'Could you step right over the valley?',
      ),
    ],
    conclusion: "That's gradient descent: measure the slope of the loss, step downhill, and keep the "
        'steps (the learning rate) small enough not to overshoot.',
  ),
  SocraticScript(
    conceptId: 'overfitting',
    opening: "Let's reason through overfitting. Answer in your own words; there are no wrong guesses.",
    steps: [
      SocraticStep(
        "A student memorises last year's exam answers word for word. How will they do on a new exam?",
        'Did they learn the subject, or only those specific questions?',
      ),
      SocraticStep(
        "For a model, what plays the role of last year's exam and of the new exam?",
        'One set it learns from, and one set it has never seen.',
      ),
      SocraticStep(
        'Which two numbers would you compare to spot this problem?',
        'Accuracy or error on each of those two sets.',
      ),
    ],
    conclusion: "That's overfitting: strong on training data, weak on new data. Compare training and "
        'validation error to catch it, and use regularisation or more data to fix it.',
  ),
  SocraticScript(
    conceptId: 'eigen',
    opening: "Let's discover eigenvectors by thinking about arrows.",
    steps: [
      SocraticStep(
        'Stretch the whole plane sideways. Do most arrows keep pointing the same way?',
        'Picture an arrow pointing diagonally before and after the stretch.',
      ),
      SocraticStep(
        'Can you find an arrow that only gets longer, without turning?',
        'Try arrows that point exactly along the stretch.',
      ),
      SocraticStep(
        "How would you write 'only gets longer' as an equation with the matrix A?",
        'A times v equals some number times v.',
      ),
    ],
    conclusion: 'Those special arrows are eigenvectors: Av = λv, where λ, the eigenvalue, is the '
        'stretch factor.',
  ),
];

const comparisons = <Comparison>[
  Comparison(
    conceptId: 'regularization',
    views: [
      SourceView('p11', 'Start with weight decay. Dropout should not be the default for small networks.'),
      SourceView('p10', 'In their experiments, dropout helped large networks more than L2 did.'),
    ],
    agreement: 'Both treat L2 / weight decay and dropout as the two main regularisers.',
    difference: 'The textbook recommends weight decay as the default; the paper found dropout '
        'stronger for large networks. Both can be true: the right choice depends on network size.',
  ),
  Comparison(
    conceptId: 'lr',
    views: [
      SourceView('p2', 'Start around 0.001 and adjust from the training curve.'),
      SourceView('p3', 'Halve the rate if the loss jumps; double it if the loss barely moves. Use schedules.'),
    ],
    agreement: 'Both say to tune the learning rate by watching the training loss.',
    difference: 'The textbook gives a starting value; the slides give an adjustment rule and add '
        'learning-rate schedules.',
  ),
  Comparison(
    conceptId: 'overfitting',
    views: [
      SourceView('p8', 'Defined by the gap between falling training error and rising validation error.'),
      SourceView('p9', 'Caused by many parameters relative to the amount of data.'),
    ],
    agreement: 'Both describe a model that fits training data much better than new data.',
    difference: 'The paper focuses on how to detect overfitting; the textbook focuses on what '
        'causes it and how to reduce it.',
  ),
  Comparison(
    conceptId: 'pca',
    views: [
      SourceView('p13', 'PCA keeps the eigenvectors with the largest eigenvalues to reduce dimensions.'),
      SourceView('p14', 'PCA keeps the directions of most spread, and can reduce overfitting.'),
    ],
    agreement: 'Both describe PCA as keeping the directions of greatest variance.',
    difference: 'Only your notes claim PCA reduces overfitting; the textbook does not say this. '
        'Check that claim with your lecturer before relying on it in the exam.',
  ),
];

// ─── Lookups ────────────────────────────────────────────────────────────────

Concept conceptById(String id) => concepts.firstWhere((c) => c.id == id);

Passage passageById(String id) => passages.firstWhere((p) => p.id == id);

List<Passage> passagesFor(String conceptId) =>
    passages.where((p) => p.concepts.contains(conceptId)).toList();

List<QuizQuestion> questionsFor(String conceptId) =>
    questionBank.where((q) => q.conceptId == conceptId).toList();

List<ConceptLink> linksFor(String conceptId) =>
    conceptLinks.where((l) => l.from == conceptId || l.to == conceptId).toList();

/// Marks for an exam passage, read from its section title, e.g. "Question 3 (12 marks)".
int marksOf(Passage p) {
  final match = RegExp(r'\((\d+) marks\)').firstMatch(p.section);
  return match == null ? 0 : int.parse(match.group(1)!);
}
